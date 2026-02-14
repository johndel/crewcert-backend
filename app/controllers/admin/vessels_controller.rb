# frozen_string_literal: true

module Admin
  class VesselsController < BaseController
    before_action :set_vessel, only: [:show, :edit, :update, :destroy, :request_all_certificates, :readiness]

    def index
      @q = Vessel.ransack(params[:q])
      @pagy, @vessels = pagy(@q.result.ordered)
    end

    def show
      @crew_members = @vessel.crew_members.includes(:role).ordered
    end

    def new
      @vessel = Vessel.new
    end

    def create
      @vessel = Vessel.new(vessel_params)

      if @vessel.save
        redirect_to admin_vessel_path(@vessel), notice: "Vessel was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @vessel.update(vessel_params)
        redirect_to admin_vessel_path(@vessel), notice: "Vessel was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @vessel.destroy
      redirect_to admin_vessels_path, notice: "Vessel was successfully deleted."
    end

    def request_all_certificates
      result = CertificateRequests::BulkSendService.call(
        vessel: @vessel,
        sent_by: current_user
      )

      if result.success?
        flash_success("Certificate requests sent to #{result.data[:sent]} crew members.")
      else
        flash_error("#{result.data[:sent]} sent, #{result.data[:failed]} failed.")
      end

      redirect_to admin_vessel_path(@vessel)
    end

    def readiness
      @crew_members = @vessel.crew_members.includes(:role, certificates: :certificate_type).ordered
      @roles = Role.where(id: @crew_members.pluck(:role_id).uniq).ordered

      # Get all required certificate types for roles on this vessel
      @required_certs_by_role = MatrixRequirement.where(vessel: @vessel, role: @roles)
                                                  .includes(:certificate_type, :role)
                                                  .group_by(&:role_id)

      # Get unique certificate types across all roles
      @certificate_types = CertificateType.where(
        id: MatrixRequirement.where(vessel: @vessel, role: @roles).select(:certificate_type_id)
      ).ordered

      # Build the readiness matrix
      @readiness_matrix = build_readiness_matrix
      @compliance_stats = calculate_compliance_stats
    end

    private

    def build_readiness_matrix
      matrix = {}

      @crew_members.each do |cm|
        matrix[cm.id] = {}
        required_certs = @required_certs_by_role[cm.role_id] || []
        cert_map = cm.certificates.index_by(&:certificate_type_id)

        required_certs.each do |req|
          cert = cert_map[req.certificate_type_id]
          status = certificate_status(cert, req)
          matrix[cm.id][req.certificate_type_id] = {
            status: status,
            certificate: cert,
            requirement: req
          }
        end
      end

      matrix
    end

    def certificate_status(cert, req)
      return :missing unless cert
      return :rejected if cert.status == 'rejected'
      return :pending if cert.status.in?(%w[pending processing])
      return :expired if cert.expired?
      return :expiring_soon if cert.expiring_soon?
      :valid
    end

    def calculate_compliance_stats
      total_required = 0
      compliant = 0
      missing = 0
      expired = 0
      expiring = 0
      pending = 0

      @readiness_matrix.each do |_cm_id, certs|
        certs.each do |_ct_id, data|
          next unless data[:requirement].mandatory?
          total_required += 1

          case data[:status]
          when :valid
            compliant += 1
          when :missing
            missing += 1
          when :expired, :rejected
            expired += 1
          when :expiring_soon
            expiring += 1
            compliant += 1 # Still compliant, just expiring
          when :pending
            pending += 1
          end
        end
      end

      percentage = total_required > 0 ? ((compliant.to_f / total_required) * 100).round : 100

      {
        total_required: total_required,
        compliant: compliant,
        missing: missing,
        expired: expired,
        expiring: expiring,
        pending: pending,
        percentage: percentage
      }
    end

    def set_vessel
      @vessel = Vessel.find(params[:id])
    end

    def vessel_params
      params.require(:vessel).permit(:name, :imo, :management_company)
    end
  end
end

# frozen_string_literal: true

module Admin
  class CertificatesController < BaseController
    before_action :set_certificate, only: [:show, :edit, :update, :destroy, :verify, :reject]
    before_action :ensure_can_modify, only: [:verify, :reject]

    def index
      @q = base_scope.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?

      scope = apply_filters(@q.result)
      @pagy, @certificates = pagy(scope)
      @pending_count = Certificate.pending_review.count
    end

    def show
      @crew_member = @certificate.crew_member
    end

    def new
      @certificate = Certificate.new
      @certificate.crew_member_id = params[:crew_member_id] if params[:crew_member_id]
      @crew_members = CrewMember.ordered.includes(:vessel, :role)
      @certificate_types = CertificateType.ordered
    end

    def create
      @certificate = Certificate.new(certificate_params)

      if @certificate.save
        flash_success("Certificate was successfully created.")
        redirect_to admin_certificate_path(@certificate)
      else
        @crew_members = CrewMember.ordered.includes(:vessel, :role)
        @certificate_types = CertificateType.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @crew_members = CrewMember.ordered.includes(:vessel, :role)
      @certificate_types = CertificateType.ordered
    end

    def update
      if @certificate.update(certificate_params)
        flash_success("Certificate was successfully updated.")
        redirect_to admin_certificate_path(@certificate)
      else
        @crew_members = CrewMember.ordered.includes(:vessel, :role)
        @certificate_types = CertificateType.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      crew_member = @certificate.crew_member
      @certificate.destroy!
      flash_success("Certificate was successfully deleted.")
      redirect_to admin_crew_member_path(crew_member)
    end

    def verify
      @certificate.verify!(current_user)
      flash_success("Certificate verified successfully.")
      redirect_back_or_to admin_certificates_path(filter: 'pending')
    end

    def reject
      reason = params[:rejection_reason]
      @certificate.reject!(current_user, reason: reason)
      flash_success("Certificate rejected.")
      redirect_back_or_to admin_certificates_path(filter: 'pending')
    end

    private

    def base_scope
      Certificate.includes(:crew_member, :certificate_type, :verified_by)
    end

    def apply_filters(scope)
      case params[:filter]
      when 'pending' then scope.pending_review
      when 'verified' then scope.verified
      when 'expiring' then scope.expiring_soon
      when 'expired' then scope.expired
      when 'rejected' then scope.rejected
      else scope
      end
    end

    def set_certificate
      @certificate = Certificate.find(params[:id])
    end

    def ensure_can_modify
      return if @certificate.can_verify?

      flash_error("This certificate cannot be modified in its current state.")
      redirect_to admin_certificate_path(@certificate)
    end

    def certificate_params
      params.require(:certificate).permit(
        :crew_member_id,
        :certificate_type_id,
        :certificate_number,
        :issue_date,
        :expiry_date,
        :document,
        :status
      )
    end

  end
end

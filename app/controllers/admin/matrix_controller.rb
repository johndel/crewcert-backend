# frozen_string_literal: true

module Admin
  class MatrixController < BaseController
    before_action :set_vessel, only: [:index, :update_requirement]
    before_action :set_roles_and_certificate_types, only: [:index]

    def index
      @matrix = build_matrix
    end

    def update_requirement
      @certificate_type = CertificateType.find(params[:certificate_type_id])
      @role = Role.find(params[:role_id])
      level = params[:level]

      requirement = MatrixRequirement.find_or_initialize_by(
        vessel: @vessel,
        role: @role,
        certificate_type: @certificate_type
      )

      if level.blank? || level == "none"
        requirement.destroy if requirement.persisted?
        @level = nil
      else
        requirement.requirement_level = level
        requirement.save!
        @level = level
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_matrix_index_path(vessel_id: @vessel.id), notice: "Requirement updated." }
      end
    end

    private

    def set_vessel
      @vessel = params[:vessel_id].present? ? Vessel.find(params[:vessel_id]) : Vessel.first
      @vessels = Vessel.ordered
    end

    def set_roles_and_certificate_types
      @roles = Role.ordered
      @certificate_types = CertificateType.ordered

      # Group certificate types by category based on code prefix
      @certificate_type_groups = @certificate_types.group_by do |ct|
        case ct.code
        when /^STCW/
          "STCW Certificates"
        when /^COC/
          "Certificates of Competency"
        when /^FLAG/
          "Flag State Certificates"
        when /^MED/
          "Medical Certificates"
        else
          "Other Certificates"
        end
      end
    end

    def build_matrix
      # Pre-load all requirements for this vessel
      requirements = MatrixRequirement.where(vessel: @vessel).index_by { |r| [r.role_id, r.certificate_type_id] }

      @certificate_types.each_with_object({}) do |ct, matrix|
        matrix[ct.id] = @roles.each_with_object({}) do |role, row|
          req = requirements[[role.id, ct.id]]
          row[role.id] = req&.requirement_level
        end
      end
    end
  end
end

# frozen_string_literal: true

class UploadsController < ApplicationController
  include RateLimitable

  layout "public"

  before_action :set_certificate_request
  before_action :check_request_valid
  before_action :set_crew_member

  # Override rate limit settings for upload controller
  def rate_limit_max_requests
    30 # 30 requests per minute for uploads
  end

  def show
    @required_certificates = MatrixRequirement
      .where(vessel: @vessel, role: @role)
      .includes(:certificate_type)
      .order("certificate_types.code")

    @existing_certificates = @crew_member.certificates
      .includes(:certificate_type)
      .index_by(&:certificate_type_id)
  end

  def upload_certificate
    @certificate_type = CertificateType.find(params[:certificate_type_id])

    # Validate certificate type is required by matrix for this crew member's role/vessel
    unless allowed_certificate_type?(@certificate_type)
      return head :forbidden
    end

    @certificate = find_or_build_certificate

    if @certificate.update(certificate_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to upload_path(token: @certificate_request.token), notice: "Certificate uploaded successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "certificate_form_#{@certificate_type.id}",
            partial: "uploads/certificate_form",
            locals: { certificate_type: @certificate_type, certificate: @certificate, certificate_request: @certificate_request }
          )
        end
        format.html do
          redirect_to upload_path(token: @certificate_request.token),
                      alert: "Failed to upload certificate: #{@certificate.errors.full_messages.join(', ')}"
        end
      end
    end
  end

  def submit
    if @certificate_request.submit!
      redirect_to upload_path(token: @certificate_request.token),
                  notice: "Thank you! Your certificates have been submitted for review."
    else
      redirect_to upload_path(token: @certificate_request.token),
                  alert: "Failed to submit. Please try again."
    end
  end

  private

  def set_certificate_request
    @certificate_request = CertificateRequest.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render "invalid_token", status: :not_found
  end

  def check_request_valid
    return render("expired", status: :gone) if @certificate_request.expired?
    return render("already_submitted") if @certificate_request.status == "submitted"
  end

  def set_crew_member
    @crew_member = @certificate_request.crew_member
    @vessel = @crew_member.vessel
    @role = @crew_member.role
  end

  def find_or_build_certificate
    @crew_member.certificates.find_or_initialize_by(certificate_type: @certificate_type)
  end

  def certificate_params
    params.permit(:certificate_number, :issue_date, :expiry_date, :document).merge(status: "pending")
  end

  def allowed_certificate_type?(certificate_type)
    MatrixRequirement.exists?(
      vessel: @vessel,
      role: @role,
      certificate_type: certificate_type
    )
  end
end

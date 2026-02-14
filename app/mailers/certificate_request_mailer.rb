# frozen_string_literal: true

class CertificateRequestMailer < ApplicationMailer
  def request_certificates(certificate_request)
    @certificate_request = certificate_request
    @crew_member = certificate_request.crew_member
    @vessel = @crew_member.vessel
    @role = @crew_member.role
    @upload_url = upload_url(token: @certificate_request.token)

    # Get required certificates for context in email
    @required_certificates = MatrixRequirement.where(vessel: @vessel, role: @role)
                                               .includes(:certificate_type)
                                               .map { |r| r.certificate_type.name }

    mail(
      to: @crew_member.email,
      subject: "Certificate Upload Request - #{@vessel.name}"
    )
  end
end

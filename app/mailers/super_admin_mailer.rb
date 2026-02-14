class SuperAdminMailer < ApplicationMailer
  default from: "noreply@crewcert.com"

  def magic_link_email(super_admin, token)
    @super_admin = super_admin
    @magic_link_url = super_admin_verify_magic_link_url(token: token)

    mail(
      to: @super_admin.email,
      subject: "Your CrewCert Login Link"
    )
  end
end

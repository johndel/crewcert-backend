class SuperAdminMailer < ApplicationMailer
  default from: "noreply@crewcert.com"

  def magic_link_email(super_admin, token)
    @super_admin = super_admin
    @magic_link_url = verify_super_admin_magic_link_url(super_admin.id, token: token)

    mail(
      to: @super_admin.email,
      subject: "Your CrewCert Login Link"
    )
  end
end

# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def magic_link(user)
    @user = user
    @magic_link_url = admin_verify_magic_link_url(token: @user.generate_token_for(:magic_link))

    mail(
      to: @user.email,
      subject: "Your CrewCert Sign In Link"
    )
  end
end

module SuperAdmins
  class MagicLinksController < ApplicationController
    layout "super_admin_auth"

    before_action :require_not_authenticated_super_admin!, only: [ :create, :new ]
    rate_limit to: 20, within: 3.minutes, only: [ :create ]

    def new
    end

    def create
      @email = params[:email]&.strip&.downcase

      if @email.blank? || !valid_email?(@email)
        flash[:alert] = "Please enter a valid email address"
        render :new, status: :unprocessable_content
        return
      end

      super_admin = SuperAdmin.find_by(email: @email)

      if super_admin.present?
        token = super_admin.generate_token_for(:magic_link)
        SuperAdminMailer.magic_link_email(super_admin, token).deliver_later
      end

      flash[:notice] = "If an account exists for #{@email}, you will receive a login link shortly."
      redirect_to new_super_admin_magic_link_path
    end

    def verify
      token = params[:token]
      return redirect_to new_super_admin_magic_link_path, alert: "Invalid or expired link" if token.blank?

      super_admin = SuperAdmin.find_by_token_for(:magic_link, token)
      if super_admin.present?
        super_admin.ensure_password!
        super_admin.remember_me = true
        sign_in(super_admin)
        super_admin.update_columns(
          sign_in_count: super_admin.sign_in_count + 1,
          current_sign_in_at: Time.current,
          last_sign_in_at: super_admin.current_sign_in_at || Time.current,
          current_sign_in_ip: request.remote_ip,
          last_sign_in_ip: super_admin.current_sign_in_ip
        )
        redirect_to super_admin_root_path, notice: "Successfully signed in!"
      else
        redirect_to new_super_admin_magic_link_path, alert: "Invalid or expired link"
      end
    end

    private

    def valid_email?(email)
      email.match?(/\A[^@\s]+@[^@\s]+\z/)
    end
  end
end

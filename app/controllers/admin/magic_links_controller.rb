# frozen_string_literal: true

module Admin
  class MagicLinksController < ApplicationController
    layout "admin_auth"

    before_action :require_not_authenticated_user!, only: [:new, :create, :verify]
    rate_limit to: 20, within: 3.minutes, only: [:create]

    def new
    end

    def create
      @user = User.find_by(email: params[:email]&.downcase&.strip)

      if @user
        UserMailer.magic_link(@user).deliver_later
      end

      # Always show success message to prevent email enumeration
      redirect_to new_admin_magic_link_path, notice: "If an account exists with that email, you will receive a magic link shortly."
    end

    def verify
      @user = User.find_by_token_for(:magic_link, params[:token])

      if @user
        sign_in(@user)
        redirect_to admin_root_path, notice: "Successfully signed in!"
      else
        redirect_to new_admin_magic_link_path, alert: "Invalid or expired magic link. Please request a new one."
      end
    end

    private

    def require_not_authenticated_user!
      if user_signed_in?
        redirect_to admin_root_path
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include ErrorHandling
    include Pagy::Method

    layout "admin"

    before_action :require_user!
    before_action :set_current_user_for_audit

    helper_method :current_admin

    private

    def require_user!
      return if user_signed_in?

      store_location_for(:user, request.fullpath) if request.get?
      redirect_to new_admin_magic_link_path, alert: "Please sign in to continue."
    end

    def current_admin
      current_user
    end

    def set_current_user_for_audit
      Current.user = current_user if defined?(Current) && current_user
    end

    # Standard pagination options
    def pagy_options
      { limit: 20 }
    end

    # Flash message helpers
    def flash_success(message)
      flash[:notice] = message
    end

    def flash_error(message)
      flash[:alert] = message
    end
  end
end

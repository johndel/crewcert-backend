# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_user!

    private

    def require_user!
      unless user_signed_in?
        redirect_to new_admin_magic_link_path, alert: "Please sign in to continue."
      end
    end
  end
end

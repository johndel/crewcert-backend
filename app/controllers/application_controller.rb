class ApplicationController < ActionController::Base
  include Pagy::Method
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_super_admin!
    return if super_admin_signed_in?

    redirect_to new_super_admin_magic_link_path, alert: "You need to sign in to continue."
  end

  def require_not_authenticated_super_admin!
    return unless super_admin_signed_in?

    redirect_to super_admin_root_path, alert: "You are already signed in."
  end

  def after_sign_in_path_for(resource)
    return super_admin_root_path if resource.is_a?(SuperAdmin)

    super
  end
end

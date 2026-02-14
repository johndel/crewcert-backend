module SuperAdmins
  class BaseController < ApplicationController
    layout "super_admin"

    before_action :require_super_admin!
  end
end

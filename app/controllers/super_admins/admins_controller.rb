module SuperAdmins
  class AdminsController < BaseController
    def index
      @super_admins = SuperAdmin.order(created_at: :desc)
    end
  end
end

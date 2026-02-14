# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    before_action :set_role, only: [:show, :edit, :update, :destroy]

    def index
      @q = Role.ransack(params[:q])
      @pagy, @roles = pagy(@q.result.ordered)
    end

    def show
    end

    def new
      @role = Role.new
    end

    def create
      @role = Role.new(role_params)

      if @role.save
        redirect_to admin_roles_path, notice: "Role was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @role.update(role_params)
        redirect_to admin_roles_path, notice: "Role was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @role.crew_members.any?
        redirect_to admin_roles_path, alert: "Cannot delete role with assigned crew members."
      else
        @role.destroy
        redirect_to admin_roles_path, notice: "Role was successfully deleted."
      end
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:name, :position)
    end
  end
end

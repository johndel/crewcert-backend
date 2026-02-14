# frozen_string_literal: true

module Admin
  class CrewMembersController < BaseController
    before_action :set_crew_member, only: [:show, :edit, :update, :destroy, :send_certificate_request]

    def index
      @q = CrewMember.includes(:vessel, :role).ransack(params[:q])
      @pagy, @crew_members = pagy(@q.result.ordered)
    end

    def show
      @certificates = @crew_member.certificates.includes(:certificate_type).order(created_at: :desc)
      @required_certificates = @crew_member.required_certificate_types
      @missing_certificates = @crew_member.missing_certificates
    end

    def new
      @crew_member = CrewMember.new
      @crew_member.vessel_id = params[:vessel_id] if params[:vessel_id]
    end

    def create
      @crew_member = CrewMember.new(crew_member_params)

      if @crew_member.save
        redirect_to admin_crew_member_path(@crew_member), notice: "Crew member was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @crew_member.update(crew_member_params)
        redirect_to admin_crew_member_path(@crew_member), notice: "Crew member was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      vessel = @crew_member.vessel
      @crew_member.destroy
      redirect_to admin_vessel_path(vessel), notice: "Crew member was successfully deleted."
    end

    def send_certificate_request
      certificate_request = @crew_member.certificate_requests.create!(status: "pending")
      certificate_request.send_request!
      redirect_to admin_crew_member_path(@crew_member), notice: "Certificate request sent to #{@crew_member.email}."
    end

    private

    def set_crew_member
      @crew_member = CrewMember.find(params[:id])
    end

    def crew_member_params
      params.require(:crew_member).permit(:vessel_id, :role_id, :first_name, :last_name, :email, :phone)
    end
  end
end

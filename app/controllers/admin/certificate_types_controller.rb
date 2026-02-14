# frozen_string_literal: true

module Admin
  class CertificateTypesController < BaseController
    before_action :set_certificate_type, only: [:show, :edit, :update, :destroy]

    def index
      @q = CertificateType.ransack(params[:q])
      @pagy, @certificate_types = pagy(@q.result.ordered)
    end

    def show
    end

    def new
      @certificate_type = CertificateType.new
    end

    def create
      @certificate_type = CertificateType.new(certificate_type_params)

      if @certificate_type.save
        redirect_to admin_certificate_types_path, notice: "Certificate type was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @certificate_type.update(certificate_type_params)
        redirect_to admin_certificate_types_path, notice: "Certificate type was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @certificate_type.certificates.any?
        redirect_to admin_certificate_types_path, alert: "Cannot delete certificate type with existing certificates."
      else
        @certificate_type.destroy
        redirect_to admin_certificate_types_path, notice: "Certificate type was successfully deleted."
      end
    end

    private

    def set_certificate_type
      @certificate_type = CertificateType.find(params[:id])
    end

    def certificate_type_params
      params.require(:certificate_type).permit(:code, :name, :description, :validity_period_months)
    end
  end
end

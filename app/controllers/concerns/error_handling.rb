# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request
  end

  private

  def not_found(exception = nil)
    Rails.logger.warn("Record not found: #{exception&.message}")

    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "admin" }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.turbo_stream { head :not_found }
    end
  end

  def unprocessable_entity(exception)
    Rails.logger.warn("Unprocessable entity: #{exception.message}")

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :unprocessable_entity }
      format.turbo_stream { head :unprocessable_entity }
    end
  end

  def bad_request(exception)
    Rails.logger.warn("Bad request: #{exception.message}")

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "Invalid request" }
      format.json { render json: { error: "Bad request" }, status: :bad_request }
      format.turbo_stream { head :bad_request }
    end
  end
end

# frozen_string_literal: true

class ApplicationService
  def self.call(...)
    new(...).call
  end

  private

  def success(data = nil)
    ServiceResult.new(success: true, data: data)
  end

  def failure(error, data = nil)
    ServiceResult.new(success: false, error: error, data: data)
  end
end

class ServiceResult
  attr_reader :data, :error

  def initialize(success:, data: nil, error: nil)
    @success = success
    @data = data
    @error = error
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

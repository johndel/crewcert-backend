# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationService do
  describe '.call' do
    # Create a test service for testing purposes
    let(:test_service_class) do
      Class.new(ApplicationService) do
        def initialize(value)
          @value = value
        end

        def call
          if @value > 0
            success(@value * 2)
          else
            failure("Value must be positive")
          end
        end
      end
    end

    it 'creates instance and calls call method' do
      result = test_service_class.call(5)
      expect(result.data).to eq(10)
    end

    it 'returns success result for valid input' do
      result = test_service_class.call(5)
      expect(result).to be_success
    end

    it 'returns failure result for invalid input' do
      result = test_service_class.call(-1)
      expect(result).to be_failure
    end

    it 'includes error message on failure' do
      result = test_service_class.call(-1)
      expect(result.error).to eq("Value must be positive")
    end
  end
end

RSpec.describe ServiceResult do
  describe '#success?' do
    it 'returns true for successful result' do
      result = ServiceResult.new(success: true, data: 'test')
      expect(result).to be_success
    end

    it 'returns false for failed result' do
      result = ServiceResult.new(success: false, error: 'error')
      expect(result).not_to be_success
    end
  end

  describe '#failure?' do
    it 'returns true for failed result' do
      result = ServiceResult.new(success: false, error: 'error')
      expect(result).to be_failure
    end

    it 'returns false for successful result' do
      result = ServiceResult.new(success: true, data: 'test')
      expect(result).not_to be_failure
    end
  end

  describe '#data' do
    it 'returns the data' do
      result = ServiceResult.new(success: true, data: { key: 'value' })
      expect(result.data).to eq({ key: 'value' })
    end
  end

  describe '#error' do
    it 'returns the error message' do
      result = ServiceResult.new(success: false, error: 'Something went wrong')
      expect(result.error).to eq('Something went wrong')
    end
  end
end

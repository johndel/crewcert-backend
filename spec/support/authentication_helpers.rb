# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in_user(user = nil)
    user ||= create(:user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:user_signed_in?).and_return(true)
    user
  end

  def sign_out_user
    allow(controller).to receive(:current_user).and_return(nil)
    allow(controller).to receive(:user_signed_in?).and_return(false)
  end
end

module RequestAuthenticationHelpers
  def sign_in_user(user = nil)
    @current_user = user || create(:user)
    # Use Warden test helpers for request specs
    login_as(@current_user, scope: :user)
    @current_user
  end

  def sign_out_user
    logout(:user)
    @current_user = nil
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :controller
  config.include RequestAuthenticationHelpers, type: :request
  config.include Warden::Test::Helpers, type: :request

  config.before(:each, type: :request) do
    Warden.test_mode!
  end

  config.after(:each, type: :request) do
    Warden.test_reset!
  end
end

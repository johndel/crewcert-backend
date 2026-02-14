# frozen_string_literal: true

module RateLimitable
  extend ActiveSupport::Concern

  included do
    before_action :check_rate_limit, if: :rate_limit_enabled?
  end

  private

  def rate_limit_enabled?
    !Rails.env.test?
  end

  def check_rate_limit
    key = rate_limit_key
    limit = rate_limit_max_requests
    period = rate_limit_period

    current_count = increment_rate_limit(key, period)

    if current_count > limit
      render_rate_limited
    end
  end

  def rate_limit_key
    "rate_limit:#{controller_name}:#{action_name}:#{request.remote_ip}"
  end

  def rate_limit_max_requests
    60 # 60 requests per period
  end

  def rate_limit_period
    1.minute
  end

  def increment_rate_limit(key, period)
    # Use Rails cache as a simple rate limiter
    # In production, consider using Redis for distributed rate limiting
    count = Rails.cache.read(key).to_i + 1
    Rails.cache.write(key, count, expires_in: period)
    count
  end

  def render_rate_limited
    respond_to do |format|
      format.html do
        render plain: "Too many requests. Please try again later.", status: :too_many_requests
      end
      format.json do
        render json: { error: "Rate limit exceeded" }, status: :too_many_requests
      end
    end
  end
end

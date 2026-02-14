Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn) || ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  config.send_default_pii = true
  config.enabled_environments = %w[production staging]

  config.traces_sampler = lambda do |context|
    unless context[:parent_sampled].nil?
      next context[:parent_sampled]
    end

    # You can also access the full rack environment for path-based decisions
    rack_env = context[:env]
    return 0.0 if rack_env && rack_env["PATH_INFO"] == "/up"

    transaction_context = context[:transaction_context]

    op = transaction_context[:op]

    case op
    when /http/
      0.1
    when /queue/
      0.05
    else
      0.0 # ignore all other transactions
    end
  end
end

Rails.application.configure do
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.execution_mode = :async
  config.good_job.max_threads = 5
  config.good_job.shutdown_timeout = 25 # seconds
  config.good_job.poll_interval = 30.seconds
  config.good_job.enable_cron = true

  config.good_job.dashboard_default_locale = :en
end

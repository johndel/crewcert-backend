source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6.2"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.2.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails", "~> 1.3.1"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.20"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "~> 2.14.1"
# Bundle and process CSS
gem "cssbundling-rails", "~> 1.4.3"

# Add env variables in .env
gem "dotenv-rails", "~> 3.2.0", groups: [ :development, :test ]

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 1.2024", platforms: %i[ windows jruby ]

# Background job processing
gem "good_job", "~> 4.13.1"

# Redis for caching and rate limiting in production
gem "redis", "~> 5.4.0"

# Google Gemini AI for document OCR
gem "gemini-ai", "~> 4.2.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.21.1", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", "~> 2.10.1", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.17", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.14.0"

# Authentication
gem "devise", "~> 5.0.0"

# CORS for API
gem "rack-cors", "~> 3.0.0"

# Error monitoring
gem "sentry-ruby", "~> 6.3.0"
gem "sentry-rails", "~> 6.3.0"

# Pagination
gem "pagy", "~> 43.3.0"
gem "simple_calendar", "~> 3.1.0"

# AWS S3 for Cloudflare R2
gem "aws-sdk-s3", "~> 1.212.0", require: false

# Audit trails
gem "paper_trail", "~> 17.0.0"

# Search and filtering
gem "ransack", "~> 4.4.1"
gem "pg_search", "~> 2.3.7"

# Performance monitoring
gem "prosopite", "~> 2.1.2"
gem "marginalia", "~> 1.11.1"

# PostgreSQL dashboard
gem "pghero", "~> 3.7.0"

# Excel handling
gem "caxlsx", "~> 4.4.1"
gem "caxlsx_rails", "~> 0.6.4"
gem "roo", "~> 3.0.0"
gem "csv", "~> 3.3.5"

# Date/time grouping
gem "groupdate", "~> 6.7.0"

# Bulk import
gem "activerecord-import", "~> 2.2.0"

gem "phonelib", "~> 0.10.15"
gem "babosa", "~> 2.0.0"
gem "countries", "~> 7.0.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11.1", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 8", require: false

  # Check for vulnerable versions of gems
  gem "bundler-audit", "~> 0.9.2", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", "~> 1.1.0", require: false

  # RSpec testing framework
  gem "rspec-rails", "~> 8.0.2"
  gem "factory_bot_rails", "~> 6.5.1"
  gem "rubocop-rspec", "~> 3.9.0", require: false

  # Test data generation
  gem "faker", "~> 3.6.0"

  # Time manipulation for tests
  gem "timecop", "~> 0.9.10"
end

group :test do
  gem "shoulda-matchers", "~> 7.0.1"
  gem "database_cleaner-active_record", "~> 2.2.2"

  # Test coverage
  gem "simplecov", "~> 0.22.0", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2.1"

  # Email preview in development
  gem "letter_opener", "~> 1.10.0"

  # Model annotation
  gem "annotaterb", "~> 4.20.0"

  gem "bullet", "~> 8.1.0"
end

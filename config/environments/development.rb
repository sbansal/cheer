require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  config.active_storage.service = :amazon

  config.active_job.queue_adapter = :resque

  config.action_mailer.default_url_options = { host: 'app.usecheer.test' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :port           => Rails.application.credentials[:sendgrid][:smtp_port],
    :address        => Rails.application.credentials[:sendgrid][:smtp_server],
    :user_name      => Rails.application.credentials[:sendgrid][:smtp_username],
    :password       => Rails.application.credentials[:sendgrid][:smtp_password],
    :domain         => 'usecheer.test',
    :authentication => :plain,
  }

  config.hosts << /.*\.usecheer\.test/
  config.hosts << /[a-z0-9]+\.ngrok\.io/

  #whitelist plaid IP addresses for webhooks
  Rails.application.credentials[:plaid][:ips_allowlist].each do |ip_address|
    config.hosts << ip_address
  end
  config.force_ssl = true

  logger           = ActiveSupport::Logger.new("log/#{Rails.env}.log")
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end

  config.action_cable.url = "wss://app.usecheer.test/cable"
  config.force_ssl = true
  config.action_cable.allowed_request_origins = ["https://app.usecheer.test"]
end

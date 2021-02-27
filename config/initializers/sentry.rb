Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry[:dsn]
  config.breadcrumbs_logger = [:active_support_logger]
  config.enabled_environments = %w[production]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end

  config.async = lambda do |event, hint|
    Sentry::SendEventJob.perform_later(event, hint)
  end

  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end

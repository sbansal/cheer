Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry[:dsn]
  config.breadcrumbs_logger = [:active_support_logger]
  config.enabled_environments = %w[production]
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    event.request.data = filter.filter(event.request.data)
    event
  end

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
end

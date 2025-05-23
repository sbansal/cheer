source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.4.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.4.0'

# frontend
# Use SCSS for stylesheets
# gem 'sass-rails', '>= 6'
# gem 'webpacker', '~> 5.0'
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "sprockets-rails"
gem "jsbundling-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.6'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'faraday'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'bullet'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # gem 'capistrano', require: false
  # gem 'capistrano-bundler', require: false
  # gem 'capistrano-rbenv', require: false
  # gem 'capistrano-rails', require: false
  # gem 'capistrano3-puma', require: false
  gem 'seed_dump'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#security
gem 'rotp'
gem 'rqrcode'
gem 'lockbox'
gem 'devise', '~>4.9.3'
gem 'aws-sdk-s3', require: false
gem 'json-jwt', '~>1.14.0'


# jobs
gem 'resque', '~> 2.4'
gem 'textacular'

#ui
gem 'pagy', '~> 3.5'
gem 'plaid'

#monitoring
gem 'sentry-ruby'
gem 'sentry-rails'
gem "sentry-resque"
gem 'newrelic_rpm'

#openai
gem "ruby-openai", "~> 4.0.0"

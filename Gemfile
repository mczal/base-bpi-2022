# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'audited', '~> 5.0'
gem 'airbrake'
gem 'asset_sync'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.4', require: false
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'clearance'
gem 'fog-aws'
gem 'google-analytics-rails', '1.1.1'

gem 'image_processing', '>= 1.2'
gem 'rmagick'

gem 'jbuilder', '~> 2.7'
gem 'kaminari'
gem 'money-rails'
gem 'newrelic_rpm'
gem 'pg'
gem 'pg_search'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'redis'
gem 'rolify'
gem 'roo'
gem 'roo-google'
gem 'sass-rails', '>= 6'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'slim-rails'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby'
gem 'webpacker', '~> 5.0'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'capybara', '>= 2.15'
gem 'nokogiri'
gem 'selenium-webdriver'
gem 'webdrivers'

group :development, :test do
  gem 'break'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'pry'
end

group :development do
  # gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rubocop', '~> 1.22', require: false
  gem 'rubocop-rails'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rbenv',   require: false
  gem 'capistrano-rails-logs-tail',   require: false
end

group :test do
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

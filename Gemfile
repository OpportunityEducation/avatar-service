# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.3.3'

# Server
gem 'sinatra'

# Image generation
gem 'rmagick'

# Monitoring
gem 'newrelic_rpm'

# Server
gem 'puma'

group :development do
  # Linting
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end

# Testing
group :test do
  gem 'rack-test'
  gem 'rspec'

  # CircleCI Likes this
  gem 'rspec_junit_formatter'
end

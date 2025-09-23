source 'https://rubygems.org'

# Basic Rails gems
gem 'activerecord-enhancedsqlite3-adapter', '~> 0.8.0'
gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.0.3'
gem 'rails-healthcheck'
gem 'solid_cable'
gem 'solid_queue', '~> 1.2'
gem 'sqlite3', '>= 1.4'
gem 'stimulus-rails'
gem 'turbo-rails'

# Rails console enhancements
gem 'awesome_print'
gem 'ostruct', require: false # Silence obsolete warnings for Ruby 3.5
gem 'pry-byebug'
gem 'pry-rails'

# Metrics
# https://dev.37signals.com/kamal-prometheus/
gem 'yabeda'
gem 'yabeda-prometheus-mmap'
gem 'yabeda-puma-plugin'
gem 'yabeda-rails'

# Application requirements
gem 'addressable'
gem 'chartkick'
gem 'chronic_duration', '>= 0.10.6'
gem 'hashie', '>= 5.0.0'
gem 'shellwords', '>= 0.2.0'

group :development, :test do
  # Hot reload on html, css, js changes
  gem 'hotwire-spark'

  # Code analysis and linting
  gem 'brakeman', require: false
  gem 'overcommit', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-faker', require: false
  gem 'rubocop-obsession', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  # Testing and mocking
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 8.0.2'
  gem 'shoulda-matchers', '~> 6.5'
end

source 'https://rubygems.org'

# Basic Rails gems
gem 'activerecord-enhancedsqlite3-adapter', '~> 0.8.0'
gem 'bootsnap', require: false
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.2.2'
gem 'rails-healthcheck'
gem 'solid_queue', '~> 1.0'
gem 'sqlite3', '>= 1.4'

# Rails console enhancements
gem 'awesome_print'
gem 'ostruct', require: false # Silence obsolete warnings for Ruby 3.5
gem 'pry-byebug'
gem 'pry-rails'

# Application requirements
gem 'addressable'
gem 'hashie', '>= 5.0.0'

group :development, :test do
  # Code analysis and linting
  gem 'brakeman', require: false
  gem 'overcommit', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-faker', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  # Testing and mocking
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 7.0.0'
  gem 'shoulda-matchers', '~> 6.0'
end

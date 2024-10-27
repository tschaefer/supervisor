# frozen_string_literal: true

Healthcheck.configure do |config|
  config.success = 200
  config.error = 503
  config.verbose = true
  config.route = '/up'
  config.method = :get

  config.add_check :database,   -> { ActiveRecord::Base.connection.execute('select 1') }
  config.add_check :migrations, -> { ActiveRecord::Migration.check_pending_migrations }
  config.add_check :environment, lambda {
    ENV.fetch('SUPERVISOR_API_KEY', nil) || Rails.application.credentials.supervisor_api_key!
  }
end

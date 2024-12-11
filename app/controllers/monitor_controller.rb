class MonitorController < ApplicationController
  def self.username
    ENV.fetch(
      'SUPERVISOR_MONITOR_USERNAME',
      Rails.application.credentials.supervisor_monitor_username
    ) || 'supervisor'
  end

  def self.password
    ENV.fetch(
      'SUPERVISOR_MONITOR_PASSWORD',
      Rails.application.credentials.supervisor_monitor_password
    ) || 'supervisor'
  end

  def dashboard
    authenticate_or_request_with_http_basic do |username, password|
      username == self.class.username && password == self.class.password
    end

    @stacks = Stack.all
  end
end

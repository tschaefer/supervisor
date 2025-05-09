class DashboardController < ApplicationController
  def self.username
    ENV.fetch(
      'SUPERVISOR_DASHBOARD_USERNAME',
      Rails.application.credentials.supervisor_monitor_username
    ) || 'supervisor'
  end

  def self.password
    ENV.fetch(
      'SUPERVISOR_DASHBOARD_PASSWORD',
      Rails.application.credentials.supervisor_monitor_password
    ) || 'supervisor'
  end

  def index
    authenticate_or_request_with_http_basic do |username, password|
      username == self.class.username && password == self.class.password
    end

    @stacks = Stack.all
  end

  def log
    authenticate_or_request_with_http_basic do |username, password|
      username == self.class.username && password == self.class.password
    end

    stack = Stack.find_by(uuid: params[:uuid])
    send_file(
      stack.assets.log_file,
      type: 'text/plain',
      disposition: 'attachment',
      filename: "#{stack.uuid}.log"
    )
  end
end

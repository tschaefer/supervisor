class MonitorController < ApplicationController
  def dashboard
    # Basic auth
    authenticate_or_request_with_http_basic do |username, password|
      username == 'admin' && password == 'password'
    end

    @stacks = Stack.all
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  allow_browser versions: :modern

  def self.api_key
    @api_key ||= lambda do
      api_key = ENV.fetch(
        'SUPERVISOR_API_KEY',
        Rails.application.credentials.supervisor_api_key
      )
      "Bearer #{api_key}"
    end.call
  end

  private

  def authorize
    api_key = request.headers.fetch('Authorization', nil)

    begin
      return if ActiveSupport::SecurityUtils.fixed_length_secure_compare(api_key, self.class.api_key)
    rescue ArgumentError, TypeError
      # api_key is nil or differs in length
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end

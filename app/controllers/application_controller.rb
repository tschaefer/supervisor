class ApplicationController < ActionController::API
  def self.api_key
    @api_key ||= ENV.fetch('SUPERVISOR_API_KEY', Rails.application.credentials.supervisor_api_key)
  end

  private

  # Callback to authorize requests with an API key.
  def authorize
    api_key = request.headers.fetch('Authorization', nil)

    begin
      return if ActiveSupport::SecurityUtils.fixed_length_secure_compare(api_key, self.class.api_key)
    rescue ArgumentError, TypeError
      # api_key is nil or differs in length
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  # Callback to validate the webhook payload signature.
  def validate_signature
    signature       = request.headers.fetch(@stack.signature_header, nil)
    algorithm, hmac = signature&.split('=')
    payload         = request.body.read
    secret          = @stack.signature_secret

    begin
      return if ActiveSupport::SecurityUtils.fixed_length_secure_compare(
        hmac,
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(algorithm), secret, payload)
      )
    rescue ArgumentError, TypeError, RuntimeError
      # signature is nil or differs in length
      # bad digest algorithm
    end

    render json: { error: 'Payload signature is invalid' }, status: :bad_request
  end
end

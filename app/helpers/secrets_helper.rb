module SecretsHelper
  def filter_secrets(hash)
    secrets = %r{key|token|passw|secret}i
    filters = [->(k, v) { v.replace('[FILTERED]') if secrets.match?(k) && v.present? }]

    filtered = ActiveSupport::ParameterFilter.new(filters).filter(hash)
    Hashie::Mash.new(filtered)
  end
end

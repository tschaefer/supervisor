module Supervisor
  class Host
    def initialize(ip = nil)
      info = fetch_info(ip)
      info.symbolize_keys!
      info.delete(:readme)

      update_instance(info)
    end

    private

    def fetch_info(ip)
      return specific(ip) if ip

      v4.merge(v6)
    end

    def specific(ip)
      JSON.parse(Net::HTTP.get(URI("https://ipinfo.io/#{ip}")))
    rescue StandardError => e
      Rails.logger.error { "Failed to fetch specific IP info: #{e.message}" }
      {}
    end

    def v4
      info = JSON.parse(Net::HTTP.get(URI('https://ipinfo.io/')))
      info['ipv4'] = info.delete('ip')

      info
    rescue StandardError => e
      Rails.logger.error { "Failed to fetch IPv4 info: #{e.message}" }
      {}
    end

    def v6
      info = JSON.parse(Net::HTTP.get(URI('https://6.ipinfo.io/')))
      info['ipv6'] = info.delete('ip')

      info
    rescue StandardError => e
      Rails.logger.error { "Failed to fetch IPv6 info: #{e.message}" }
      {}
    end

    def update_instance(info)
      info.each do |key, value|
        define_singleton_method(key) { value }
      end

      define_singleton_method(:to_h) { info }
      define_singleton_method(:to_json) { info.to_json }
    end
  end
end

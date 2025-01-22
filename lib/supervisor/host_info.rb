module Supervisor
  class HostInfo
    def initialize(hostname_or_ip)
      ip = effective_ip(hostname_or_ip)
      hostname = effective_hostname(hostname_or_ip)

      info = {}

      ipaddr = IPAddr.new(ip)
      if ipaddr.private? || ipaddr.loopback? || ipaddr.link_local?
        info[:ip] = ip
        info[:hostname] = hostname
      else
        info = fetch_info
        info.symbolize_keys!
        info[:ip] = ip
        info[:hostname] = hostname
        info.delete(:readme)
      end

      update_instance(info)
    end

    private

    def effective_ip(hostname_or_ip)
      return hostname_or_ip if (hostname_or_ip =~ Resolv::AddressRegex).present?

      begin
        resolver = Resolv::DNS.new.tap { |r| r.timeouts = 1 }
        resolver.getaddress(hostname_or_ip).to_s
      rescue Resolv::ResolvError
        Rails.logger.error { "Failed to resolve hostname #{hostname_or_ip}" }
        nil
      end
    end

    def effective_hostname(hostname_or_ip)
      return hostname_or_ip if (hostname_or_ip =~ Resolv::AddressRegex).nil?

      begin
        resolver = Resolv::DNS.new.tap { |r| r.timeouts = 1 }
        resolver.getname(hostname_or_ip).to_s
      rescue Resolv::ResolvError
        Rails.logger.error { "Failed to resolve IP #{@ip}" }
        nil
      end
    end

    def fetch_info
      JSON.parse(Net::HTTP.get(URI("https://ipinfo.io/#{@ip}")))
    rescue StandardError => e
      Rails.logger.error { "Failed to fetch IP info for #{ip}: #{e.message}" }
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

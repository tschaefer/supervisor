module Supervisor
  class HostInfo
    attr_reader :hostname, :ip, :location

    def initialize(hostname_or_ip)
      @hostname_or_ip = hostname_or_ip
      @resolver = Resolv::DNS.new.tap { |r| r.timeouts = 1 }

      @ip = effective_ip
      @hostname = effective_hostname
      @location = effective_location
    end

    def to_h
      { hostname: hostname, ip: ip, location: location }
    end

    def to_json(*)
      to_h.to_json(*)
    end

    private

    def effective_ip
      return @hostname_or_ip if (@hostname_or_ip =~ Resolv::AddressRegex).present?

      begin
        @resolver.getaddress(@hostname_or_ip).to_s
      rescue Resolv::ResolvError
        Rails.logger.error { "Failed to resolve hostname #{@hostname_or_ip}" }
        '-'
      end
    end

    def effective_hostname
      return @hostname_or_ip if (@hostname_or_ip =~ Resolv::AddressRegex).nil?

      @resolver.getname(@ip).to_s
    rescue Resolv::ResolvError
      Rails.logger.error { "Failed to resolve IP #{@ip}" }
      '-'
    end

    def effective_location
      return '-' if IPAddr.new(@ip).private? || IPAddr.new(@ip).loopback?

      info = begin
        JSON.parse(Net::HTTP.get(URI("http://ipinfo.io/#{@ip}")))
      rescue StandardError => e
        Rails.logger.error { "Failed to fetch IP info for #{ip}: #{e.message}" }
        {}
      end

      info.slice('city', 'region', 'country', 'org').values.join(', ') || 'Unknown'
    end
  end
end

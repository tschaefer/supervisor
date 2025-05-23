module HostInfoHelper
  OSM_MARKER_URL = 'https://www.openstreetmap.org/?mlat=%s&mlon=%s#map=17/%s/%s'.freeze

  def host_info
    server_name = request.server_name

    info = Rails.cache.fetch(server_name, expires_in: 1.day) do
      Supervisor::Host.new.to_h
    end

    location = format_location(info)
    ip = format_ip(info)

    # rubocop:disable Rails/OutputSafety
    "IP: #{ip} | Location: #{location}".html_safe
    # rubocop:enable Rails/OutputSafety
  end

  private

  def format_ip(info)
    "#{info[:ipv4] || '-'} / #{info[:ipv6] || '-'}"
  end

  def format_location(info)
    location = %i[city region country org].filter_map do |key|
      next if info[key].blank?

      info[key]
    end.join(', ')

    return '-' if location.blank?

    lat, lon = info[:loc].split(',')
    link_to(location, format(OSM_MARKER_URL, lat, lon, lat, lon), class: 'link-secondary')
  end
end

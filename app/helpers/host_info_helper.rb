module HostInfoHelper
  def host_info
    server_name = request.server_name

    info = Rails.cache.fetch(server_name, expires_in: 1.day) do
      Supervisor::HostInfo.new(server_name).to_h
    end

    location = %i[city region country org].filter_map do |key|
      next if info[key].blank?

      info[key]
    end.join(', ')
    location = '-' if location.blank?

    "Hostname: #{info[:hostname]} | IP: #{info[:ip]} | Location: #{location}"
  end
end

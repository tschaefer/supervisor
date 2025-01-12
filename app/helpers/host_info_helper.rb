module HostInfoHelper
  def host_info
    server_name = request.server_name

    info = Rails.cache.fetch(server_name, expires_in: 1.day) do
      Supervisor::HostInfo.new(server_name)
    end

    "Hostname: #{info.hostname} | Address: #{info.ip} | Location: #{info.location}"
  end
end

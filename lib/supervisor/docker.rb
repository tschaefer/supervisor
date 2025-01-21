module Supervisor
  class Docker
    def info
      bin = '/usr/bin/sudo'
      args = %w[/usr/bin/docker info --format json]

      stdout, stderr, status = Open3.capture3(bin, *args)
      raise "Failed to run docker info: #{stderr}" unless status.success?

      hash = JSON.parse(stdout)
      {
        containers: hash['Containers'],
        containers_running: hash['ContainersRunning'],
        containers_paused: hash['ContainersPaused'],
        containers_stopped: hash['ContainersStopped'],
        images: hash['Images'],
        server_version: hash['ServerVersion'],
        storage_driver: hash['Driver']
      }
    end
  end
end

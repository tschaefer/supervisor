module Supervisor
  class Docker
    def initialize
      info = run_docker_info
      hash = parse_docker_info(info)

      update_instance(hash)
    end

    private

    def run_docker_info
      bin = '/usr/bin/sudo'
      args = %w[/usr/bin/docker info --format json]

      stdout, stderr, status = Open3.capture3(bin, *args)
      raise "Failed to run docker info: #{stderr}" unless status.success?

      stdout
    end

    def parse_docker_info(info)
      hash = JSON.parse(info)
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

    def update_instance(info)
      info.each do |key, value|
        define_singleton_method(key) { value }
      end

      define_singleton_method(:to_h) { info }
      define_singleton_method(:to_json) { info.to_json }
    end
  end
end

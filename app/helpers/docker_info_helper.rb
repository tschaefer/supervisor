module DockerInfoHelper
  def docker_info
    Hashie::Mash.new(Supervisor::Docker.new.info)
  end
end

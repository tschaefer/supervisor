module DockerInfoHelper
  def docker_info
    Supervisor::Docker.new.to_h
  end
end

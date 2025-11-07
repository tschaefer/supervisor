pyroscope_server_address = ENV.fetch('SUPERVISOR_PYROSCOPE_SERVER_ADDRESS', nil)
return if pyroscope_server_address.blank?

require 'pyroscope'

Pyroscope.configure do |config|
  config.application_name    = ENV.fetch('SUPERVISOR_PYROSCOPE_APPLICATION_NAME', 'github.com/tschaefer/supervisor')
  config.server_address      = pyroscope_server_address
  config.detect_subprocesses = true
end

print "* Profiling enabled. Sending data to #{pyroscope_server_address}\n" # rubocop:disable Rails/Output

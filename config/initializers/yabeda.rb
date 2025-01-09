require 'prometheus/client/support/puma'

Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

Yabeda.configure do
  group :supervisor do
    counter :stack_processed_count, comment: 'Total number of stack jobs processed', tags: %i[name action status]
  end
end

Yabeda.configure!

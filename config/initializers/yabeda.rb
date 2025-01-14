require 'prometheus/client/support/puma'

Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

Yabeda.configure do
  group :supervisor do
    counter :stack_jobs_executed_total do
      comment 'Total number of stack jobs executed'
      tags %i[name action status]
    end
    counter :stack_jobs_failed_total do
      comment 'Total number of failed stack jobs'
      tags %i[name action]
    end
    counter :stack_jobs_succeeded_total do
      comment 'Total number of succeeded stack jobs'
      tags %i[name action]
    end
    histogram :stack_jobs_runtime do
      comment 'Total time taken to execute stack jobs'
      unit :seconds
      buckets [
        0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10,
        30, 60, 120, 300, 1800, 3600, 86_400
      ].freeze
    end
  end
end

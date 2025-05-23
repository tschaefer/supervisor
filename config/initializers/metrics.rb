require 'prometheus/client/support/puma'

Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

Yabeda.configure do
  group :supervisor do
    counter :stack_jobs_executed_total do
      comment 'The total number of stack jobs executed.'
      tags %i[name action status]
    end
    counter :stack_jobs_failed_total do
      comment 'The total number of stack jobs that failed.'
      tags %i[name action]
    end
    counter :stack_jobs_succeeded_total do
      comment 'The total number of stack jobs that succeeded.'
      tags %i[name action]
    end
    histogram :stack_jobs_execution_time do
      comment 'The time taken to execute stack jobs, measured in seconds.'
      unit :seconds
      buckets [
        0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10,
        30, 60, 120, 300, 1800, 3600, 86_400
      ].freeze
    end
    gauge :total_stacks do
      comment 'The total number of stacks.'
      aggregation :sum
    end
    gauge :total_healthy_stacks do
      comment 'The total number of healthy stacks.'
      aggregation :sum
    end
    gauge :total_unhealthy_stacks do
      comment 'The total number of unhealthy stacks.'
      aggregation :sum
    end

    collect do
      supervisor.total_stacks.set({}, Stack.count)
      supervisor.total_healthy_stacks.set({}, Stack.where(healthy: true).count)
      supervisor.total_unhealthy_stacks.set({}, Stack.where(healthy: false).count)
    end
  end
end

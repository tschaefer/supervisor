class StackRestartJob < StackJob
  include StackJob::RunsControlScript

  queue_as :deploy

  action :restart
end

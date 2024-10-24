class StackDeployJob < StackJob
  include StackJob::RunsDeployScript

  queue_as :deploy
end

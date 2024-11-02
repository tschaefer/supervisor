class StackStartJob < StackJob
  include StackJob::RunsControlScript

  queue_as :deploy

  action :start
end

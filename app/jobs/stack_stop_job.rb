class StackStopJob < StackJob
  include StackJob::RunsControlScript

  queue_as :deploy

  action :stop
end

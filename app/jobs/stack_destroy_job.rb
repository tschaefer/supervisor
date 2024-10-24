class StackDestroyJob < StackJob
  include StackJob::RunsDestroyScript

  queue_as :deploy

  def execute
    script = render_script(@stack, @assets)
    run_script(script)
  end
end

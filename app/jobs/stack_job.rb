class StackJob < ApplicationJob
  include StackJob::HandlesExecuteResult
  include StackJob::HasScriptTemplate

  STACKS_ROOT = ENV.fetch('SUPERVISOR_STACKS_ROOT', Rails.root.join('storage/stack'))

  def perform(stack)
    # On destroy, the relevant stack attributes are passed as a hash
    @stack = stack.is_a?(Hash) ? Hashie::Mash.new(stack) : stack

    include_files = @stack.compose_includes.join(' ')
    @assets = @stack.assets
                    .merge(include_files:)

    execute
  end

  private

  def execute
    script = render_script(@stack, @assets)
    run_script(script)
    stack_log
    return if noop?

    stats_jobs = [
      StackDeployJob,
      StackPollingJob,
      StackWebhookJob
    ]
    return if stats_jobs.exclude?(self.class)

    @stack.update_stats(failed: error?)
  end

  def render_script(stack, assets)
    template_path = Rails.root.join("app/jobs/stack_job/templates/#{self.class.script_template}.sh.tt")
    template = File.read(template_path)

    ERB.new(template, trim_mode: '-').result(binding)
  end

  def run_script(script)
    @stdouterr, status = Open3.capture2e({}, script)
    @status = status.exitstatus
  end
end

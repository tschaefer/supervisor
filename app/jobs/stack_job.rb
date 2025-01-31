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
    script = ERB.new(
      Rails.root.join("app/jobs/stack_job/templates/#{self.class.script_template}.sh.tt").read,
      trim_mode: '-'
    ).result(binding)

    output = nil
    status = nil
    Yabeda.supervisor.stack_jobs_execution_time.measure do
      output, status = Open3.capture2e({}, script)
    end
    return if instance_of?(StackDestroyJob)

    stack_log(output, status)
    stack_stats(status)
    stack_health(status)
  end
end

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
    stack_stats
  end

  def render_script(stack, assets)
    ERB.new(
      Rails.root.join("app/jobs/stack_job/templates/#{self.class.script_template}.sh.tt").read,
      trim_mode: '-'
    ).result(binding)
  end

  def run_script(script)
    @stdouterr, status = Open3.capture2e({}, script)
    @status = status.exitstatus
  end
end

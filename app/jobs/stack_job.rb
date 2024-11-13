class StackJob < ApplicationJob
  include StackJob::HandlesExecuteResult
  include StackJob::HasScriptTemplate

  STACKS_ROOT = ENV.fetch('SUPERVISOR_STACKS_ROOT', Rails.root.join('storage/stack'))

  def perform(stack)
    # On destroy, the relevant stack attributes are passed as a hash
    @stack = stack.is_a?(Hash) ? Hashie::Mash.new(stack) : stack
    @assets = build_assets

    execute
  end

  private

  def build_assets
    assets = {}.tap do |hash|
      base_dir = STACKS_ROOT.join(@stack.uuid)

      hash[:base_dir] = base_dir.to_s
      hash[:env_file] = base_dir.join('stack.env').to_s
      hash[:git_dir] = base_dir.join('git').to_s
      hash[:include_files] = @stack.compose_includes.join(' ')
    end
    Hashie::Mash.new(assets)
  end

  def execute
    script = render_script(@stack, @assets)
    run_script(script)

    stats_jobs = [
      StackDeployJob,
      StackPollingJob,
      StackWebhookJob
    ]
    return if stats_jobs.exclude?(self.class)
    return if noop?

    @stack.update_stats(failed: error?)
  end

  def render_script(stack, assets)
    template_path = Rails.root.join("app/jobs/stack_job/templates/#{self.class.script_template}.sh.tt")
    template = File.read(template_path)

    ERB.new(template, trim_mode: '-').result(binding)
  end

  def run_script(script)
    stdouterr, status = Open3.capture2e({}, script)
    @status = status.exitstatus

    Rails.logger.error { "[#{@stack.uuid}] #{stdouterr}" } if error?
  end
end

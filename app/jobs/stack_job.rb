class StackJob < ApplicationJob
  include StackJob::HandlesExecuteResult

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

      hash[:base_dir] = base_dir
      hash[:env_file] = base_dir.join('stack.env')
      hash[:git_dir] = base_dir.join('git')
      hash[:include_files] = @stack.compose_includes.map { |i| "--file #{i}" }.join(' ')
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

  def render_script(*)
    raise "#{self.class} must implement the method #{__method__}"
  end

  def run_script(script)
    stdouterr, status = Open3.capture2e({}, script)
    @status = status.exitstatus

    if success? || noop?
      Rails.logger.info { "Succeded #{self.class} (Stack UUID: #{@stack.uuid})" }
      Rails.logger.debug { stdouterr }
    else
      Rails.logger.error { "Failed #{self.class} (Stack UUID: #{@stack.uuid})" }
      Rails.logger.error { stdouterr }
    end
  end
end

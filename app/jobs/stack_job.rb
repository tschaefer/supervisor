class StackJob < ApplicationJob
  include StackJob::HandlesExecuteResult
  include StackJob::HasScriptTemplate

  STACKS_ROOT = ENV.fetch('SUPERVISOR_STACKS_ROOT', Rails.root.join('storage/stack'))

  def perform(stack)
    @stack = stack.is_a?(Hash) ? Hashie::Mash.new(stack) : stack

    include_files = @stack.compose_includes.join(' ')
    @assets = @stack.assets.merge(include_files:)

    return if !instance_of?(StackDestroyJob) && !lock_for_stack!

    execute
  end

  private

  def lock_for_stack!
    lock_file = File.join(@assets.base_dir.to_s, '.lock')
    FileUtils.mkdir_p(@assets.base_dir)

    File.open(lock_file, File::RDWR | File::CREAT) do |f|
      unless f.flock(File::LOCK_EX | File::LOCK_NB)
        Rails.logger.info("StackJob: lock held for #{@stack.uuid}, exiting early")
        return false
      end
      f.flock(File::LOCK_UN)
    end

    true
  rescue StandardError => e
    Rails.logger.error("StackJob: lock check failed: #{e.message}")
  end

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

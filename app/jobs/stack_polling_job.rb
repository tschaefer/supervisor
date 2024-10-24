class StackPollingJob < StackJob
  include StackJob::RunsUpdateScript

  queue_as :polling

  private

  def execute
    return if @stack.webhook?

    reschedule

    super
  end

  def reschedule
    self.class.set(wait: @stack.polling_interval).perform_later(@stack)
  end
end

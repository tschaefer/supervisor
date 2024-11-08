class StackPollingJob < StackJob
  queue_as :polling
  script_template :update

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

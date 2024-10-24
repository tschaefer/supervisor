class StackWebhookJob < StackJob
  include StackJob::RunsUpdateScript

  queue_as :deploy

  private

  def execute
    return if @stack.polling?

    super
  end
end

class StackWebhookJob < StackJob
  queue_as :deploy
  script_template :update

  private

  def execute
    return if @stack.polling?

    super
  end
end

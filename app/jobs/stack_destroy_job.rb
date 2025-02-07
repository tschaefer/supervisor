class StackDestroyJob < StackJob
  queue_as :deploy
  script_template :destroy
end

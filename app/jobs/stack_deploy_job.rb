class StackDeployJob < StackJob
  queue_as :deploy
  script_template :deploy
end

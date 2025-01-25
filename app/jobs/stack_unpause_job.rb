class StackUnpauseJob < StackJob
  include StackJob::HasControlCommand

  queue_as :deploy
  script_template :control
  control_command :unpause
end

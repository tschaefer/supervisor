class StackPauseJob < StackJob
  include StackJob::HasControlCommand

  queue_as :deploy
  script_template :control
  control_command :pause
end

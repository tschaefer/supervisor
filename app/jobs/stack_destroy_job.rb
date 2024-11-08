class StackDestroyJob < StackJob
  queue_as :deploy
  script_template :destroy

  def execute
    script = render_script(@stack, @assets)
    run_script(script)
  end
end

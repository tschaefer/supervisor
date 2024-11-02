class StackJob
  module RunsControlScript
    extend ActiveSupport::Concern

    included do
      private

      def render_script(stack, assets)
        <<~SCRIPT
          #!/bin/sh
          set -e

          control_stack() {
            cd #{assets.git_dir}

            sudo docker --log-level error \
              compose --progress plain \
              --file #{stack.compose_file} #{assets.include_files} \
              --env-file #{assets.env_file} \
              #{self.class.action} || true
          }

          control_stack
        SCRIPT
      end
    end

    class_methods do
      def action(name = nil)
        if name.present?
          @action = name.to_s
        elsif defined?(@action)
          @action
        else
          @action = 'start'
        end
      end
    end
  end
end

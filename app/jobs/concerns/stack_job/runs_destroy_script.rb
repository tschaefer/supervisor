class StackJob
  module RunsDestroyScript
    extend ActiveSupport::Concern

    included do
      private

      def render_script(stack, assets)
        <<~SCRIPT
          #!/bin/sh

          remove_stop_stack() {
            if [ ! -d #{assets.git_dir} ]; then
              return
            fi

            cd #{assets.git_dir}

            sudo docker --log-level error \
              compose --progress plain \
              --file #{stack.compose_file} #{assets.include_files} \
              --env-file #{assets.env_file} \
              down

            cd -
          }

          remove_stop_stack
          rm -rf #{assets.base_dir}
        SCRIPT
      end
    end
  end
end

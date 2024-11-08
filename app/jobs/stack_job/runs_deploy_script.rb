class StackJob
  module RunsDeployScript
    extend ActiveSupport::Concern

    included do
      private

      def render_script(stack, assets)
        <<~SCRIPT
          #!/bin/sh
          set -e

          stop_remove_stack() {
            if [ ! -d #{assets.git_dir} ]; then
              return
            fi

            cd #{assets.git_dir}

            sudo docker --log-level error \
              compose --progress plain \
              --file #{stack.compose_file} #{assets.include_files} \
              --env-file #{assets.env_file} \
              down || true

            cd -
          }

          clone_prepare_stack() {
            rm -rf #{assets.base_dir}

            git clone #{stack.url.normalize} #{assets.git_dir}

            cd #{assets.git_dir}

            local reference
            reference=$(git show-ref --dereference --tags #{stack.git_reference} | tail -n 1 | cut -d ' ' -f 1)
            reference=${reference:-#{stack.git_reference}}

            git fetch origin +${reference}:#{stack.uuid}
            git checkout #{stack.uuid}
            printf "%s\n" '#{stack.environment}' > #{assets.env_file}

            cd -
          }

          create_start_stack() {
            cd #{assets.git_dir}

            sudo docker --log-level error \
              compose --progress plain \
              --file #{stack.compose_file} #{assets.include_files} \
              --env-file #{assets.env_file} \
              up --detach

            cd -
          }

          stop_remove_stack
          clone_prepare_stack
          create_start_stack
        SCRIPT
      end
    end
  end
end

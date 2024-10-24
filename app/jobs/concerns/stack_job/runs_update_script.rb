class StackJob
  module RunsUpdateScript
    extend ActiveSupport::Concern

    included do
      private

      def render_script(stack, assets)
        <<~SCRIPT
          #!/bin/sh

          fetch_diff_stack() {
            cd #{assets.git_dir}
            git fetch origin #{stack.git_reference}
            git diff --quiet FETCH_HEAD && exit 254
            cd -
          }

          has_changed_stack() {
            cd #{assets.git_dir}

            has_changes="false"
            for file in $(git diff --name-only origin); do
                if [ "$file" = "#{stack.compose_file}" ]; then
                        has_changes="true"
                        break
                fi

                if [ -z "#{assets.include_files}" ]; then
                  continue
                fi

                OIFS=$IFS
                IFS=' '
                for include in "#{assets.include_files}"; do
                  if [ "$file" = "$include" ]; then
                      has_changes="true"
                      break
                  fi
                done
                IFS=$OIFS
            done

            if [ "$has_changes" = "false" ]; then
              exit 254
            fi

            cd -
          }

          stop_remove_stack() {
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

          create_start_stack() {
            cd #{assets.git_dir}

            git merge FETCH_HEAD

            sudo docker --log-level error \
              compose --progress plain \
              --file #{stack.compose_file} #{assets.include_files} \
              --env-file #{assets.env_file} \
              up --detach

            cd -
          }

          set -e
          fetch_diff_stack
          has_changed_stack

          set +e
          stop_remove_stack

          set -e
          create_start_stack
        SCRIPT
      end
    end
  end
end

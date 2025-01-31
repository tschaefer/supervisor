class StackJob
  module HandlesExecuteResult
    extend ActiveSupport::Concern

    included do
      private

      def stack_log(output, status)
        stack_log_file = @stack.assets.log_file.to_s
        File.open(stack_log_file, 'a') do |log|
          log.puts(
            {
              run_at: Time.now.utc.iso8601(3),
              action: __action,
              status: status.success? ? 'succeeded' : 'failed',
              message: output
            }.to_json
          )
        end
      end

      def stack_stats(status)
        @stack.update_stats(succeeded: status.success?, action: __action)
      end

      def stack_health(status)
        @stack.update(healthy: status.success?)
      end

      def __action
        self.class.name.titleize.split.second.downcase
      end
    end
  end
end

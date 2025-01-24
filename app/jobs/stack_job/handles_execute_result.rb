class StackJob
  module HandlesExecuteResult
    extend ActiveSupport::Concern

    included do
      private

      const_set(:OK, 0)
      const_set(:NOOP, 254)

      def success?
        [OK, NOOP].include?(@status)
      end

      def error?
        !success?
      end

      def stack_log
        Rails.logger.error { "[#{@stack.uuid}] #{@stdouterr}" } if error?

        stack_log_file = @stack.assets.log_file.to_s
        File.open(stack_log_file, 'a') do |log|
          log.puts(
            {
              run_at: Time.now.utc.iso8601(3),
              action: __action,
              status: success? ? 'succeeded' : 'failed',
              message: @stdouterr
            }.to_json
          )
        end
      end

      def stack_stats
        @stack.update_stats(succeeded: success?, action: __action)
      end

      def stack_health
        @stack.update(healthy: success?)
      end

      def __action
        self.class.name.titleize.split.second.downcase
      end
    end
  end
end

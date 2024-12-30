class StackJob
  module HandlesExecuteResult
    extend ActiveSupport::Concern

    included do
      private

      const_set(:OK, 0)
      const_set(:NOOP, 254)

      def success?
        @status == OK
      end

      def noop?
        @status == NOOP
      end

      def error?
        !success? && !noop?
      end

      def op?
        !noop?
      end

      def stack_log
        Rails.logger.error { "[#{@stack.uuid}] #{@stdouterr}" } if error?
        return if instance_of?(StackDestroyJob)

        stack_log_file = @stack.assets.log_file.to_s
        File.open(stack_log_file, 'a') do |log|
          log.puts({ created_at: Time.now.utc.iso8601(3), message: __log_message }.to_json)
        end
        @stack.touch
      end

      def stack_stats
        stats_jobs = [
          StackDeployJob,
          StackPollingJob,
          StackWebhookJob
        ]
        return if stats_jobs.exclude?(self.class)

        @stack.update_stats(processed: op?, failed: error?)
      end

      def __log_message
        action = self.class.name.titleize.humanize.chomp(' job')

        if success?
          "#{action} succeeded"
        elsif noop?
          "#{action} was a no-op"
        else
          "#{action} failed"
        end
      end
    end
  end
end

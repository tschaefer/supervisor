class StackJob
  module HandlesExecuteResult
    extend ActiveSupport::Concern

    included do
      private

      const_set(:OK, 0)
      const_set(:NOOP, 254)

      def success?
        @status == OK || @status == NOOP
      end

      def error?
        !success?
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
        @stack.update_stats(failed: error?, action: __action.split.second)
      end

      def __action
        self.class.name.titleize.humanize.chomp(' job')
      end

      def __log_message
        action = __action

        if success?
          "#{action} succeeded"
        else
          "#{action} failed"
        end
      end
    end
  end
end

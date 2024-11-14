class StackJob
  module HandlesExecuteResult
    extend ActiveSupport::Concern

    included do
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

      def stack_log
        Rails.logger.error { "[#{@stack.uuid}] #{@stdouterr}" } if error?
        return if instance_of?(StackDestroyJob)

        stack_log_file = Pathname.new(@assets.base_dir).join('stack.log')
        File.open(stack_log_file, 'a') do |log|
          log.puts({ timestamp: Time.now.utc.iso8601, message: @stdouterr }.to_json)
        end
      end
    end
  end
end

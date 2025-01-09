class Stack
  module HasStats
    extend ActiveSupport::Concern

    included do
      def stats
        Hashie::Mash.new(
          processed:,
          failed:,
          last_run:,
          last_action:
        )
      end

      def update_stats(succeeded: false, action: nil)
        update(
          processed: processed + 1,
          failed: succeeded ? failed : failed + 1,
          last_run: Time.current,
          last_action: action || 'unknown'
        )

        Yabeda.supervisor.stack_processed_count.increment(
          {
            name: name,
            action: last_action,
            status: succeeded ? 'succeeded' : 'failed'
          },
          by: 1
        )
      end
    end
  end
end

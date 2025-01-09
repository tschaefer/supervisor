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

      def update_stats(failed: false, action: nil)
        processed = self.processed + 1
        failed = failed ? self.failed + 1 : self.failed
        last_run = processed ? Time.current : self.last_run
        last_action = action || 'unknown'

        update(
          processed: processed,
          failed: failed,
          last_run: last_run,
          last_action: last_action
        )
      end
    end
  end
end

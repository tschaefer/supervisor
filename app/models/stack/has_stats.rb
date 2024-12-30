class Stack
  module HasStats
    extend ActiveSupport::Concern

    included do
      def stats
        Hashie::Mash.new(
          processed:,
          failed:,
          last_run:
        )
      end

      def update_stats(processed: false, failed: false)
        healthy = !failed

        processed = processed ? self.processed + 1 : self.processed
        failed = failed ? self.failed + 1 : self.failed
        last_run = processed ? Time.current : self.last_run

        update(
          processed: processed,
          failed: failed,
          last_run: last_run,
          healthy: healthy
        )
      end
    end
  end
end

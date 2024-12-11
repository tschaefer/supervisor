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

      def update_stats(failed: false)
        processed = self.processed + 1
        healthy = !failed
        failed = failed ? self.failed + 1 : self.failed
        last_run = Time.current

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

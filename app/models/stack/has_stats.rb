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
        failed = self.failed + 1 if failed
        last_run = Time.current

        update(
          processed: processed,
          failed: failed,
          last_run: last_run
        )
      end
    end
  end
end
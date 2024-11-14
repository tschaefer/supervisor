class StacksController
  module StreamsLog
    extend ActiveSupport::Concern

    included do
      private

      def stream_logs(sse)
        log = open_log_file!(sse)
        return if log.nil? # return early if log file not found

        begin
          while File.exist?(log.path)
            changes = log.read
            sse.write(changes.strip, event: 'message') if changes.present?
            sleep 0.1
          end

          send_close_message(sse, 'EOF')
        rescue ActionController::Live::ClientDisconnected, Errno::EPIPE
          # Handle client disconnection or broken pipe
        ensure
          close_resources(log, sse)
        end
      end

      def open_log_file!(sse)
        log_file = StackJob::STACKS_ROOT.join(@stack.uuid, 'stack.log')

        if !File.exist?(log_file)
          send_close_message(sse, 'No log file found')
          return nil
        end

        log = File.open(log_file, 'r')
        log.seek(0, IO::SEEK_END) # Start at end of file
        log
      end

      def send_close_message(sse, message)
        sse.write({ timestamp: Time.now.utc.iso8601, message: message }.to_json, event: 'close')
        sse.close
      end

      def close_resources(log, sse)
        log&.close
        sse&.close
      end
    end
  end
end

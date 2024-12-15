class Stack
  module ReadsLog
    extend ActiveSupport::Concern

    included do
      def read_log(file_path, entries: 1)
        entries = [entries, 100].min
        buffer_size = 1024
        last_entries = []

        File.open(file_path, 'r') do |file|
          leftover = ''
          file.seek(0, IO::SEEK_END)

          position = file.pos
          while position.positive? && last_entries.size < entries
            position, chunk = read_chunk(file, position, buffer_size)
            last_entries, leftover = process_chunk(chunk, leftover, last_entries, position, entries)

            break if last_entries.size >= entries
          end

          last_entries.unshift(leftover) unless leftover.empty?
        end

        last_entries.last(entries).filter_map do |entry|
          JSON.parse(entry)
        rescue JSON::ParserError
          next
        end
      end

      private

      def read_chunk(file, position, buffer_size)
        read_size = [buffer_size, position].min
        position -= read_size
        file.seek(position, IO::SEEK_SET)
        [position, file.read(read_size)]
      end

      def process_chunk(chunk, leftover, last_entries, position, entries)
        entries_in_chunk = (chunk + leftover).split("\n")
        leftover = entries_in_chunk.shift unless position.zero?
        last_entries = last_entries.unshift(*entries_in_chunk).last(entries)
        [last_entries, leftover]
      end
    end
  end
end

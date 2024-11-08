class StackJob
  module HasControlCommand
    extend ActiveSupport::Concern

    class_methods do
      def control_command(name = nil)
        name.nil? ? @control_command : @control_command = name.to_s
      end
    end
  end
end

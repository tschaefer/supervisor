class StackJob
  module HasScriptTemplate
    extend ActiveSupport::Concern

    class_methods do
      def script_template(name = nil)
        name.nil? ? @script_template : @script_template = name.to_s
      end
    end
  end
end

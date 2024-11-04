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
    end
  end
end

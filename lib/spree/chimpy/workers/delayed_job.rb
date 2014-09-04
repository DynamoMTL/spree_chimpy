module Spree::Chimpy
  module Workers
    class DelayedJob
      def initialize(payload)
        @payload = payload
      end

      def perform
        Spree::Chimpy.perform(@payload)
      end

      def max_attempts
        return 3
      end
    end
  end
end

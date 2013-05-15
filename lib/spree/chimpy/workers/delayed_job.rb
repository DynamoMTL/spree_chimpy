module Spree::Chimpy
  module Workers
    class DelayedJob
      def initialize(payload)
        @payload = payload
      end

      def perform
        Spree::Chimpy.perform(@payload)
      end
    end
  end
end

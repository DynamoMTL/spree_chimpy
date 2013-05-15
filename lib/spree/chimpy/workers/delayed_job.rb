module Spree::Chimpy
  module Workers
    class DelayedJob
      def initialize(payload)
        @payload = payload
      end

      def perform
        Spree::Chimpy.process_event(@payload)
      end
    end
  end
end

module Spree::Chimpy
  module Workers
    class DelayedJob
      delegate :log, to: Spree::Chimpy
      CONNECTION_TERMINATED = [Excon::Errors::Timeout,
                               Excon::Errors::SocketError]

      def initialize(payload)
        @payload = payload
      end

      def perform
        Spree::Chimpy.perform(@payload)
      rescue *CONNECTION_TERMINATED
        log "Mailchimp connection timeout reached, closing"
      end

      def max_attempts
        return 3
      end
    end
  end
end

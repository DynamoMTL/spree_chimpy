module Spree::Chimpy
  module Workers
    class Sidekiq
      delegate :log, to: Spree::Chimpy
      CONNECTION_TERMINATED = [Excon::Errors::Timeout,
                               Excon::Errors::SocketError]
      if defined?(::Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options queue: :mailchimp, retry: 3,
          backtrace: true
      end

      def perform(payload)
        Spree::Chimpy.perform(payload)
      rescue *CONNECTION_TERMINATED
        log "Mailchimp connection timeout reached, closing"
      end

    end
  end
end

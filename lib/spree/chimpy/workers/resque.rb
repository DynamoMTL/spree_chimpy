module Spree::Chimpy
  module Workers
    class Resque
      delegate :log, to: Spree::Chimpy

      QUEUE = :default
      @queue = QUEUE

      def self.perform(payload)
        Spree::Chimpy.perform(payload.with_indifferent_access)
      rescue Excon::Errors::Timeout, Excon::Errors::SocketError
        log "Mailchimp connection timeout reached, closing"
      end
    end
  end
end

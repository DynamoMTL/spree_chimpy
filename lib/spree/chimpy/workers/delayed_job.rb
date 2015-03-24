module Spree::Chimpy
  module Workers
    class DelayedJob
      delegate :log, to: Spree::Chimpy

      def initialize(payload)
        @payload = payload
      end

      def perform
        Spree::Chimpy.perform(@payload)
      rescue Excon::Errors::Timeout, Excon::Errors::SocketError
        log 'Mailchimp connection timeout reached, closing'
      rescue Mailchimp::CampaignDoesNotExistError
        log 'Mailchimp campaign no longer exists'
      end

      def max_attempts
        return 3
      end
    end
  end
end

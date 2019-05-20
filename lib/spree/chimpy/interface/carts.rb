module Spree::Chimpy
  module Interface
    class Carts
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize
      end

      def add(cart)
        CartUpserter.new(cart).upsert
      end

      def remove(cart)
        log "Attempting to remove cart #{cart.number}"

        begin
          store_api_call.carts(cart.number).delete
        rescue Gibbon::MailChimpError => e
          log "error removing #{cart.number} | #{e.raw_body}"
        end
      end

      def sync(cart)
        add(cart)
      rescue Gibbon::MailChimpError => e
        log "invalid ecomm cart error [#{e.raw_body}]"
      end

    end
  end
end

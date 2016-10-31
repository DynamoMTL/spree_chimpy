module Spree::Chimpy
  module Interface
    class Orders
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize
      end

      def add(order)
        OrderUpserter.new(order).upsert
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        begin
          store_api_call.orders(order.number).delete
        rescue Gibbon::MailChimpError => e
          log "error removing #{order.number} | #{e.raw_body}"
        end
      end

      def sync(order)
        add(order)
      rescue Gibbon::MailChimpError => e
        log "invalid ecomm order error [#{e.raw_body}]"
      end

    end
  end
end

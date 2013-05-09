module Spree::Chimpy
  module Interface
    class Orders
      API_VERSION = '1.3'

      def initialize(key)
        @api       = Hominid::API.new(key, api_version: API_VERSION)
      end

      def add(order)
        log "Adding order #{order[:id]}"

        @api.ecomm_order_add(order)
      end

      def remove(number)
        log "Attempting to remove order #{number}"

        @api.ecomm_order_del(Config.preferred_store_id, number)
      end

    private
      def log(message)
        Rails.logger.info "MAILCHIMP: #{message}"
      end
    end
  end
end

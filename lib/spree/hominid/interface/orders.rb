module Spree::Hominid
  module Interface
    class Orders
      API_VERSION = '1.3'

      def initialize(key)
        @api       = Hominid::API.new(key, api_version: API_VERSION)
      end

      def add(order, email_id=nil)
        log "Adding order #{order.number}"

        items = order.line_items.map do |line|
          variant = line.variant

          {product_id:   variant.id,
           sku:          variant.sku,
           product_name: variant.name,
           cost:         variant.cost_price,
           qty:          line.quantity}
        end

        @api.ecomm_order_add(id:         order.number,
                             email_id:   email_id,
                             email:      order.email,
                             total:      order.total,
                             order_date: order.completed_at,
                             shipping:   order.ship_total,
                             tax:        order.tax_total,
                             store_name: Spree::Config.preferred_site_name,
                             store_id:   Spree::Hominid::Config.preferred_store_id,
                             items:      items)
      end

      def remove(number)
        log "Removing order #{number}"

        @api.ecomm_order_del(Config.preferred_store_id, number)
      end

      def exists?(number)
      end

    private
      def log(message)
        Rails.logger.info "MAILCHIMP: #{message}"
      end
    end
  end
end

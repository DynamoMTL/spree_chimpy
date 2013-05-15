module Spree::Chimpy
  module Interface
    class Orders
      NOT_FOUND_FAULT = 330

      delegate :log, to: Spree::Chimpy

      def initialize(key)
        @api = Hominid::API.new(key, api_version: Spree::Chimpy::API_VERSION)
      end

      def add(order)
        log "Adding order #{order.number}"

        @api.ecomm_order_add(hash(order))
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        begin
          @api.ecomm_order_del(Config.preferred_store_id, order.number)
        rescue Hominid::APIError => e
          raise(e) unless e.fault_code == NOT_FOUND_FAULT
        end
      end

      def sync(order)
        remove(order) and add(order)
      end

    private
      def hash(order)
        source = order.source

        items = order.line_items.map do |line|
          variant = line.variant

          {product_id:   variant.id,
           sku:          variant.sku,
           product_name: variant.name,
           cost:         variant.cost_price.to_f,
           qty:          line.quantity}
        end

        data = {
          id:          order.number,
          email:       order.email,
          total:       order.total.to_f,
          order_date:  order.completed_at,
          shipping:    order.ship_total.to_f,
          tax:         order.tax_total.to_f,
          store_name:  Spree::Config.preferred_site_name,
          store_id:    Spree::Chimpy::Config.preferred_store_id,
          items:       items
        }

        if source
          data[:email_id]    = source.email_id
          data[:campaign_id] = source.campaign_id
        end

        data
      end

    end
  end
end

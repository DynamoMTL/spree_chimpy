require File.join(Rails.root, 'lib/helpers/currency_conversion.rb')

module Spree::Chimpy
  module Interface
    class Orders
      include Helpers::CurrencyConversion
      delegate :log, to: Spree::Chimpy

      def initialize
        @api = Spree::Chimpy.api
      end

      def add(order)
        log "Adding order #{order.number}"

        response = @api.ecomm.order_add(hash(order))
        log "Order #{order.number} added successfully!" if response["complete"]
        response["complete"]
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        response = @api.ecomm.order_del(Spree::Chimpy::Config.store_id, order.number)
        log "Order #{order.number} removed successfully!" if response["complete"]
        response["complete"]
      end

      def sync(order)
        remove(order) rescue nil
        add(order)
      end

    private
      def hash(order)
        source = order.source

        items = order.line_items.map do |line|
          variant = line.variant
          product = variant.product
          
          category_name = product.martin_type ? product.martin_type.title : product.product_type
          category_id = product.martin_type ? product.martin_type.id : 9999

          {product_id:    variant.id,
           sku:           variant.sku,
           product_name:  variant.name,
           category_id:   category_id,
           category_name: category_name,
           cost:          to_usd(line.base_price.to_f, line.currency),
           qty:           line.quantity}
        end

        data = {
          id:          order.number,
          email:       order.email,
          total:       order.total.to_f,
          order_date:  order.completed_at.strftime('%Y-%m-%d'),
          shipping:    order.ship_total.to_f,
          tax:         order.tax.to_f,
          store_name:  Spree::Config.site_name,
          store_id:    Spree::Chimpy::Config.store_id,
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

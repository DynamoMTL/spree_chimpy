module Spree::Chimpy
  module Interface
    class Orders
      delegate :log, to: Spree::Chimpy

      def initialize
        @api = Spree::Chimpy.api
      end

      def add(order)
        log "Adding order #{order.number}"
        order_hash = hash(order)
        if order_hash[:items].present?

          response = safe_add(order, order_hash)

          if !response.nil? and response["complete"]
            log "Order #{order.number} added successfully!" 
            true
          else
            Rails.logger.error "Order #{order.number} not added!" 
            false
          end

        else
          log "Order #{order.number} did not have any valid lines!"
        end
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

      def safe_add(order, order_hash)
        response = nil
        begin
          response = @api.ecomm.order_add(order_hash)
        rescue Mailchimp::InvalidEcommOrderError => e
          if e.message.match(/Order Id \"#{order.number}\" has already been recorded/)
            Rails.logger.error "Order #{order.number} was not added as it has already been recorded!" 
          else
            raise e
          end
        end
        response
      end

      def hash(order)
        source = order.source

        items = order.line_items.map do |line|
          variant = line.variant
          product = variant.product

          {
             product_id:    variant.id,
             sku:           variant.sku,
             product_name:  variant.name,
             category_id:   product.marketing_type.id,
             category_name: product.marketing_type.name,
             cost:          to_usd(line.base_price.to_f, line.currency),
             qty:           line.quantity
           }
        end

        data = {
          id:          order.number,
          email:       order.email,
          total:       to_usd(order.total.to_f, order.currency),
          order_date:  order.completed_at.strftime('%Y-%m-%d'),
          shipping:    to_usd(order.ship_total.to_f, order.currency),
          tax:         to_usd(order.display_tax_total.money.to_f, order.currency),
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

      def to_usd(price, currency, quantity = 1)
        return 0 unless price
        rates = Spree::Chimpy::Config.to_usd_rates
        (quantity * price  * rates[currency]).to_f
      end
    end
  end
end

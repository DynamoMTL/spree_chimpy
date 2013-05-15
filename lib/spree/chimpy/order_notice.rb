module Spree::Chimpy
  class OrderNotice
    NOT_FOUND_FAULT = 330

    def initialize(order)
      @order = order

      sync if Config.configured?
    end

    def sync
      Spree::Chimpy.fire_event(:order, order: @order)
    end

    def remove
      begin
        Config.orders.remove(@order.number)
      rescue Hominid::APIError => e
        raise(e) unless e.fault_code == NOT_FOUND_FAULT
      end
    end

    def add
      Config.orders.add(hash) unless @order.canceled?
    end

  private
    def hash
      source = @order.source

      items = @order.line_items.map do |line|
        variant = line.variant

        {product_id:   variant.id,
         sku:          variant.sku,
         product_name: variant.name,
         cost:         variant.cost_price.to_f,
         qty:          line.quantity}
      end

      data = {
        id:          @order.number,
        email:       @order.email,
        total:       @order.total.to_f,
        order_date:  @order.completed_at,
        shipping:    @order.ship_total.to_f,
        tax:         @order.tax_total.to_f,
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

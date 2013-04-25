module Spree::Hominid
  class OrderNotice
    def initialize(order)
      @order = order

      sync if Config.configured?
    end

    def sync
      remove
      add
    end

    def remove
      Config.orders.remove(@order.number) rescue nil
    end

    def add
      Config.orders.add(hash) unless @order.canceled?
    end
  private
    def hash
      items = @order.line_items.map do |line|
        variant = line.variant

        {product_id:   variant.id,
         sku:          variant.sku,
         product_name: variant.name,
         cost:         variant.cost_price,
         qty:          line.quantity}
      end

      {
        id:          @order.number,
        email:       @order.email,
        total:       @order.total,
        order_date:  @order.completed_at,
        shipping:    @order.ship_total,
        tax:         @order.tax_total,
        store_name:  Spree::Config.preferred_site_name,
        store_id:    Spree::Hominid::Config.preferred_store_id,
        items:       items
      }
    end
  end
end

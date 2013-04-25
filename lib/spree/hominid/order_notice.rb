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
      Config.orders.add(@order) unless @order.canceled?
    end
  end
end

module Spree::Hominid
  class OrderNotice
    def initialize(order)
      @order = order

      sync
    end

    def sync
      if Config.configured?
        remove if exists?
        add unless @order.canceled?
      end
    end

    def exists?
      Config.orders.exists?(@order.number)
    end

    def remove
      Config.orders.remove(@order.number)
    end

    def add
      Config.orders.add(@order)
    end
  end
end

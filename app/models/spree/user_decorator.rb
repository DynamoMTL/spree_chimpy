if Spree.user_class
  Spree.user_class.class_eval do
    after_destroy :unsubscribe
    around_update :resubscribe

    delegate :subscribe, :update_member_info, :unsubscribe, :resubscribe, to: :subscription


    def first_name
      chimpy_shipping_address.firstname if chimpy_shipping_address
    end

    def last_name
      chimpy_shipping_address.lastname if chimpy_shipping_address
    end

    def country
      chimpy_shipping_address.country.name if chimpy_shipping_address && chimpy_shipping_address.country
    end

    def city
      chimpy_shipping_address.city if chimpy_shipping_address
    end

    def number_of_orders
      chimpy_orders.count
    end

    def total_orders_amount
      last_order = chimpy_orders.last
      if last_order
        to_gbp(chimpy_orders.sum(:item_total), last_order.currency).round(2)
      else
        0
      end
    end

    def average_basket_size
      (total_orders_amount > 0) ? (total_orders_amount / number_of_orders).round(2) : 0.00
    end

    def city
      chimpy_shipping_address.city if chimpy_shipping_address
    end

    def source
      action = Spree::Chimpy::Action.where(email: email, action: :subscribe).last
      action.source if action
    end

  private
    def subscription
      Spree::Chimpy::Subscription.new(self)
    end

    def chimpy_shipping_address
      @chimpy_shipping_address ||= begin
        if shipping_address
          shipping_address
        else
          last_complete_order = orders.complete.last
          if last_complete_order
            last_complete_order.shipping_address 
          else
            last_guest_order = Spree::Order.where(email: self.email).last
            last_guest_order.shipping_address if last_guest_order
          end
        end
      end
    end

    def chimpy_orders
      @chimpy_orders ||= begin
        if enrolled? and orders.complete.any?
          orders
        else
          Spree::Order.complete.where(email: self.email)
        end
      end
    end

    def to_gbp(price, currency, quantity = 1)
      rates = Spree::Chimpy::Config.to_gbp_rates
      (quantity * price  * rates[currency]).to_f
    end

  end
end

if Spree.user_class
  Spree.user_class.class_eval do
    after_destroy :unsubscribe

    delegate :subscribe, :update_mailchimp_info, :unsubscribe, to: :subscription


    def first_name
      shipping_address.firstname
    end

    def last_name
      shipping_address.lastname
    end

    def country
      if shipping_address
        shipping_address.country.name
      else
        last_complete_order = orders.complete.last
        if last_complete_order && last_complete_order.shipping_address
          last_complete_order.shipping_address.country.name
        end
      end
    end

    def city
      if shipping_address
        shipping_address.city
      else
        last_complete_order = orders.complete.last
        if last_complete_order && last_complete_order.shipping_address
          last_complete_order.shipping_address.city
        end
      end
    end

    def source
      action = Spree::Chimpy::Action.where(email: email, action: :subscribe).first
      action.source if action
    end

  private
    def subscription
      Spree::Chimpy::Subscription.new(self)
    end
  end
end

if Spree.user_class
  Spree.user_class.class_eval do
    after_destroy :unsubscribe

    delegate :subscribe, :update_member_info, :unsubscribe, to: :subscription


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
          last_complete_order.shipping_address if last_complete_order
        end
      end
    end


  end
end

if Spree.user_class
  Spree.user_class.class_eval do
    after_create  :subscribe
    around_update :resubscribe
    after_destroy :unsubscribe
    after_initialize :assign_subscription_default

    delegate :subscribe, :resubscribe, :unsubscribe, to: :subscription


    def first_name
      shipping_address.firstname
    end

    def last_name
      shipping_address.lastname
    end

    def country
      shipping_address.country.name
    end

  private
    def subscription
      Spree::Chimpy::Subscription.new(self)
    end

    def assign_subscription_default
      self.subscribed = Spree::Chimpy::Config.subscribed_by_default if new_record?
    end
  end
end

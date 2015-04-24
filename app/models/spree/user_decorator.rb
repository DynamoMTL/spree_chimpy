if Spree.user_class
  Spree.user_class.class_eval do

    after_create  :subscribe
    after_destroy :unsubscribe
    after_initialize :assign_subscription_default

    delegate :subscribe, :resubscribe, :unsubscribe, to: :subscription

  private
    def subscription
      Spree::Chimpy::Subscription.new(self)
    end

    def assign_subscription_default
      self.subscribed ||= Spree::Chimpy::Config.subscribed_by_default if new_record?
    end
  end
end

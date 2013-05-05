if Spree.user_class
  Spree.user_class.class_eval do
    attr_accessible :subscribed

    after_create  :subscribe
    around_update :resubscribe
    after_destroy :unsubscribe

    delegate :subscribe, :resubscribe, :unsubscribe, to: :subscription

  private
    def subscription
      Spree::Hominid::Subscription.new(self)
    end
  end
end
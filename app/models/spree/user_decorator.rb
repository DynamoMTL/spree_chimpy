Spree::User.class_eval do
  after_create  :subscribe_to_mailchimp
  around_update :sync_with_mailchimp
  after_destroy :unsubscribe_from_mailchimp

private
  def subscription
    SpreeHominid::Subscription.new(self)
  end

  def subscribe_to_mailchimp
    subscription.subscribe
  end

  def sync_with_mailchimp
    yield
    subscription.sync
  end

  def unsubscribe_from_mailchimp
    subscription.unsubscribe
  end
end

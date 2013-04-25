Spree::User.class_eval do
  extend Forwardable

  attr_accessible :subscribed

  after_create  :subscribe
  around_update :sync_subscription
  after_destroy :unsubscribe

  def_delegators :subscription, :subscribe, :unsubscribe

private
  def_delegator :subscription, :sync, :sync_subscription

  def subscription
    Spree::Hominid::Subscription.new(self)
  end
end

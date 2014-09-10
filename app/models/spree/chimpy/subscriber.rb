class Spree::Chimpy::Subscriber < ActiveRecord::Base
  self.table_name = "spree_chimpy_subscribers"
  validates :email, presence: true

  after_create  :subscribe
  around_update :resubscribe
  after_destroy :unsubscribe

  delegate :subscribe, :resubscribe, :unsubscribe, to: :subscription

private
  def subscription
    Spree::Chimpy::Subscription.new(self)
  end
end

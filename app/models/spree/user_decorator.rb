Spree::User.class_eval do
  after_create  :subscribe_to_mailchimp
  after_update  :sync_with_mailchimp
  after_destroy :unsubscribe_from_mailchimp

private
  def subscribe_to_mailchimp
    SpreeHominid::List.subscribe(self)
  end

  def sync_with_mailchimp
    SpreeHominid::List.sync(self)
  end

  def unsubscribe_from_mailchimp
    SpreeHominid::List.unsubscribe(self)
  end
end

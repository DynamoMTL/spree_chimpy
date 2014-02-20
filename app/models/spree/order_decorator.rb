Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  register_update_hook :notify_mail_chimp

  around_save :handle_cancelation

  def notify_mail_chimp
    if completed? && Spree::Chimpy.configured?
      if self.user && self.user.subscribed?
        self.user.update_member_info
      else
        user = Spree.user_class.where(email: self.email, subscribed: true).first
        user.update_member_info if user
      end

      Spree::Chimpy.enqueue(:order, self) 
    end
  end

private
  def handle_cancelation
    canceled = state_changed? && canceled?
    yield
    notify_mail_chimp if canceled
  end
end

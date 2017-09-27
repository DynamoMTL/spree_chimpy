Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  state_machine do
    after_transition :to => :complete, :do => :notify_mail_chimp
  end

  around_save :handle_cancelation
  after_save :handle_mailchimp_cart

  def notify_mail_chimp
    Spree::Chimpy.enqueue(:order, self) if email.present? && Spree::Chimpy.configured?
  end

  private
  def handle_cancelation
    canceled = state_changed? && canceled?
    yield
    notify_mail_chimp if canceled
  end

  # Email is not available when transit from registration page to address page.
  def handle_mailchimp_cart
    notify_mail_chimp if email.present? && state == 'address'
  end
end

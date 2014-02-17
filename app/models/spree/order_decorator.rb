Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  register_update_hook :notify_mail_chimp

  around_save :handle_cancelation

  def notify_mail_chimp
    Spree::Chimpy.enqueue(:order, self) if completed? && Spree::Chimpy.configured?
  end

private
  def handle_cancelation
    canceled = state_changed? && canceled?
    yield
    notify_mail_chimp if canceled
  end
end

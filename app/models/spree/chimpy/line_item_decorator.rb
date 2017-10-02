Spree::LineItem.class_eval do
  after_destroy :notify_mail_chimp

  def notify_mail_chimp
    Spree::Chimpy.enqueue(:order, order) if order.email.present? && Spree::Chimpy.configured?
  end
end
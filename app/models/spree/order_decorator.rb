Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Hominid::OrderSource'

  register_update_hook :notify_mail_chimp

private
  def notify_mail_chimp
    Spree::Hominid::OrderNotice.new(self) if completed?
  end
end

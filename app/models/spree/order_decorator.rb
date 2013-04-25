Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Hominid::OrderSource'

  after_save :notify_mail_chimp, if: :completed?

private
  def notify_mail_chimp
    Spree::Hominid::OrderNotice.new(self)
  end
end

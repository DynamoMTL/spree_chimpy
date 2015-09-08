class Spree::Chimpy::BatchSubscriber
  def initialize(list_name, double_opt_in, referee_emails)
    @list_name = list_name
    @double_opt_in = double_opt_in
    @referee_emails = referee_emails
  end

  def perform
    list = Spree::Chimpy::Interface::List.new(@list_name, 'customers', @double_opt_in)
    list.batch_subscribe(@referee_emails)
  end
end

class Spree::Chimpy::ListSubscriber
  def initialize(list_name, double_opt_in, email, source)
    @list_name = list_name
    @double_opt_in = double_opt_in
    @email = email
    @source = source
  end

  def perform
    list = Spree::Chimpy::Interface::List.new(@list_name, 'customers', @double_opt_in)
    list.direct_subscribe(@email, {"SOURCE" => @source})
  end
end

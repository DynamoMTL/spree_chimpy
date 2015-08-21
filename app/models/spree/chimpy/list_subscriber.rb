
class Spree::Chimpy::ListSubscriber
  def initialize(list_name, double_opt_in, email, source)
    @list = Spree::Chimpy::Interface::List.new(list_name, 'customers', double_opt_in)
    @email = email
    @source = source
  end

  def perform
    @list.direct_subscribe(@email, {"SOURCE" => @source})
  end
end

require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new('1234') }
  let(:api)       { mock(:api) }
  let(:order)     { FactoryGirl.build_stubbed(:order) }

  before do
    Spree::Chimpy::Config.key = '1234'
    Mailchimp::API.should_receive(:new).with('1234',  {:throws_exceptions=>true, :timeout=>60}).and_return(api)
  end

  it "adds an order" do
    Spree::Config.site_name = "Super Store"
    Spree::Chimpy::Config.store_id = "super-store"

    api.should_receive(:ecomm_order_add) { |h| h[:order][:id].should == order.number }.and_return(true)

    interface.add(order).should be_true
  end

  it "removes an order" do
    Spree::Chimpy::Config.store_id = "super-store"
    api.should_receive(:ecomm_order_del).with({store_id: 'super-store', order_id: order.number}).and_return(true)

    interface.remove(order).should be_true
  end
end

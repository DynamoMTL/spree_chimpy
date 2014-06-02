require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new }
  let(:api)       { double('api', ecomm: double) }
  let(:order)     { FactoryGirl.create(:completed_order_with_totals) }
  let(:true_response) { {"complete" => true } }

  before do
    Spree::Chimpy.stub(:api).and_return(api)
    # we need to have a saved order in order to have a non-nil order number
    # we need to stub :notify_mail_chimp otherwise sync will be called on the order on update!
    order.stub(:notify_mail_chimp).and_return(true_response)
    allow_any_instance_of(Spree::Product).to receive(:marketing_type).and_return(double(id: 1, name: 'Marketing Type'))
    allow_any_instance_of(Spree::LineItem).to receive(:base_price).and_return(10.99)
  end

  it "adds an order" do
    Spree::Config.site_name = "Super Store"
    Spree::Chimpy::Config.store_id = "super-store"

    api.ecomm.should_receive(:order_add) { |h| h[:id].should == order.number }.and_return(true_response)

    expect(interface.add(order)).to be true
  end

  it "removes an order" do
    Spree::Chimpy::Config.store_id = "super-store"
    api.ecomm.should_receive(:order_del).with('super-store', order.number).and_return(true_response)

    expect(interface.remove(order)).to be true
  end
end

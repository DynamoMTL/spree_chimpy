require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new }
  let(:api)       { double() }
  let(:order)     { FactoryGirl.build(:completed_order_with_totals) }

  before do
    Spree::Chimpy::Config.key = '1234'
    Mailchimp::API.should_receive(:new).with('1234', { timeout: 60 }).and_return(api)

    # we need to have a saved order in order to have a non-nil order number
    # we need to stub :notify_mail_chimp otherwise sync will be called on the order on update!
    order.stub(:notify_mail_chimp).and_return(true)
    order.save
  end

  it "adds an order" do
    Spree::Config.site_name = "Super Store"
    Spree::Chimpy::Config.store_id = "super-store"

    api.should_receive(:ecomm_order_add) { |h| h[:order][:id].should == order.number }.and_return(true)

    interface.add(order).should be_true
  end

  it "removes an order" do
    Spree::Chimpy::Config.store_id = "super-store"
    api.should_receive(:ecomm_order_del).with({store_id: 'super-store', order_id: order.number, throws_exceptions: false}).and_return(true)

    interface.remove(order).should be_true
  end
end

require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new }
  let(:api)       { double() }

  def create_order(options={})
    user = FactoryGirl.create(:user, email: options[:email])
    order = FactoryGirl.build(:completed_order_with_totals, user: user, email: options[:email])
    order.source = Spree::Chimpy::OrderSource.new(email_id: options[:email_id])

    # we need to have a saved order in order to have a non-nil order number
    # we need to stub :notify_mail_chimp otherwise sync will be called on the order on update!
    order.stub(:notify_mail_chimp).and_return(true)
    order.save
    order
  end

  before do
    Spree::Chimpy::Config.key = '1234'
    Spree::Chimpy::Config.store_id = "super-store"
    Spree::Config.site_name = "Super Store"

    Mailchimp::API.should_receive(:new).with('1234', { timeout: 60 }).and_return(api)
  end

  context "adding an order" do
    it "sync when member info matches" do
      order = create_order(email_id: 'id-abcd', email: 'user@example.com')

      api.should_receive(:info).with('id-abcd').and_return(email: 'User@Example.com')
      api.should_receive(:ecomm_order_add) { |h| h[:order][:id].should == order.number }.and_return(:response)

      interface.add(order).should == :response
    end

    it "skips mismatches member" do
      order = create_order(email_id: 'id-abcd', email: 'user@example.com')

      api.should_receive(:info).with('id-abcd').and_return({email: 'other@home.com'})
      api.should_not_receive(:ecomm_order_add)

      interface.add(order)
    end
  end

  it "removes an order" do
    order = create_order(email: 'foo@example.com')

    api.should_receive(:ecomm_order_del).with({store_id: 'super-store', order_id: order.number, throws_exceptions: false}).and_return(true)

    interface.remove(order).should be_true
  end
end

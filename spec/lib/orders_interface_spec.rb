require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new }
  let(:api)       { double() }
  let(:list)      { double() }

  def create_order(options={})
    user = FactoryGirl.create(:user, email: options[:email])
    order = FactoryGirl.build(:completed_order_with_totals, user: user, email: options[:email])
    order.source = Spree::Chimpy::OrderSource.new(email_id: options[:email_id], campaign_id: options[:campaign_id])

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
    Spree::Chimpy::Config.subscribe_to_list = true
    Spree::Chimpy.stub(list: list)

    Mailchimp::API.should_receive(:new).with('1234', { timeout: 60 }).and_return(api)
  end

  context "adding an order" do
    it "sync when member info matches" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')

      list.should_receive(:info).with('id-abcd').and_return(email: 'User@Example.com')
      api.should_receive(:ecomm_order_add) do |h|
        h[:order][:id].should == order.number
        h[:order][:email_id].should == 'id-abcd'
        h[:order][:campaign_id].should == '1234'
      end

      interface.add(order)
    end

    it "skips mismatches member" do
      order = create_order(email_id: 'id-abcd', email: 'user@example.com')

      list.should_receive(:info).with('id-abcd').and_return({email: 'other@home.com'})
      api.should_receive(:ecomm_order_add) do |h|
        h[:order][:id].should == order.number
        h[:order][:email_id].should be_nil
        h[:order][:campaign_id].should be_nil
      end

      interface.add(order)
    end

    it 'skips subscription if manually turned off in config' do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      Spree::Chimpy::Config.subscribe_to_list = false

      expect(list).to receive(:info).with('id-abcd').and_return(email: 'user@example.com')
      expect(list).to_not receive(:subscribe).with('user@example.com')
      expect(api).to receive(:ecomm_order_add) do |h|
        expect(h[:order][:id]).to eq order.number
        expect(h[:order][:email_id]).to eq 'id-abcd'
        expect(h[:order][:campaign_id]).to eq '1234'
      end

      interface.add(order)
    end
  end

  it "removes an order" do
    order = create_order(email: 'foo@example.com')
    api.should_receive(:order_del).with('super-store', order.number).and_return(true)
    expect(interface.remove(order)).to be_true
  end
end

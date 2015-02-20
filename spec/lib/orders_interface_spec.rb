require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { described_class.new }
  let(:api)       { double(:api) }
  let(:list)      { double() }
  let(:key)       { 'e025fd58df5b66ebd5a709d3fcf6e600-us8' }

  def create_order(options={})
    user  = create(:user, email: options[:email])
    order = build(:completed_order_with_totals, user: user, email: options[:email])
    order.source = Spree::Chimpy::OrderSource.new(email_id: options[:email_id], campaign_id: options[:campaign_id])

    # we need to have a saved order in order to have a non-nil order number
    # we need to stub :notify_mail_chimp otherwise sync will be called on the order on update!
    order.stub(:notify_mail_chimp).and_return(true)
    order.save
    order
  end

  before do
    Spree::Chimpy::Config.key = key
    Spree::Chimpy::Config.store_id = "super-store"
    Spree::Chimpy::Config.subscribe_to_list = true
    Spree::Chimpy.stub(list: list)

    Mailchimp::API.should_receive(:new).with(key, { timeout: 60 }).and_return(api)
    allow(api).to receive(:ecomm).and_return(api)
  end

  context "adding an order" do
    it "sync when member info matches" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      allow(list).to receive(:info).with('id-abcd').and_return(email: 'User@Example.com')
      expect(list).to receive(:subscribe).with('User@Example.com').and_return(nil)
      expect(api).to receive(:order_add) do |h|
        expect(h[:id]).to eq order.number
        expect(h[:email_id]).to eq 'id-abcd'
        expect(h[:campaign_id]).to eq '1234'
      end

      interface.add(order)
    end

    it "skips mismatches member" do
      order = create_order(email_id: 'id-abcd', email: 'user@example.com')

      list.should_receive(:info).with('id-abcd').and_return({email: 'other@home.com'})
      expect(list).to receive(:subscribe).with('other@home.com').and_return(nil)
      api.should_receive(:order_add) do |h|
        expect(h[:id]).to eq order.number
        expect(h[:email_id]).to be_nil
        expect(h[:campaign_id]).to be_nil
      end

      interface.add(order)
    end

    it 'skips subscription if manually turned off in config' do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      Spree::Chimpy::Config.subscribe_to_list = false

      expect(list).to receive(:info).with('id-abcd').and_return(email: 'user@example.com')
      expect(list).to_not receive(:subscribe).with('user@example.com')
      expect(api).to receive(:order_add) do |h|
        expect(h[:id]).to eq order.number
        expect(h[:email_id]).to eq 'id-abcd'
        expect(h[:campaign_id]).to eq '1234'
      end

      interface.add(order)
    end
  end

  it "removes an order" do
    order = create_order(email: 'foo@example.com')
    api.should_receive(:order_del).with('super-store', order.number).and_return(true)
    expect(interface.remove(order)).to be_truthy
  end
end

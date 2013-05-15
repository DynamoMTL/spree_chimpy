require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new('1234') }
  let(:api)       { mock(:api) }
  let(:order)     { FactoryGirl.build_stubbed(:order) }

  before do
    Spree::Chimpy::Config.preferred_key = '1234'
    Hominid::API.should_receive(:new).with('1234', api_version: '1.3').and_return(api)
  end

  it "adds an order" do
    Spree::Config.preferred_site_name = "Super Store"
    Spree::Chimpy::Config.preferred_store_id = "super-store"

    api.should_receive(:ecomm_order_add).with(hash_including(id: order.number)).and_return(true)

    interface.add(order).should be_true
  end

  it "removes an order" do
    Spree::Chimpy::Config.preferred_store_id = "super-store"
    api.should_receive(:ecomm_order_del).with('super-store', order.number).and_return(true)

    interface.remove(order).should be_true
  end
end

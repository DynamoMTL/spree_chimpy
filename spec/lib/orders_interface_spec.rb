require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { Spree::Chimpy::Interface::Orders.new('1234') }
  let(:api)       { mock(:api) }

  before do
    Spree::Chimpy::Config.preferred_key = '1234'
    Hominid::API.should_receive(:new).with('1234', api_version: '1.3').and_return(api)
  end

  it "adds an order" do
    Spree::Config.preferred_site_name = "Super Store"
    Spree::Chimpy::Config.preferred_store_id = "super-store"

    api.should_receive(:ecomm_order_add).with(id: 1234).and_return(true)

    interface.add(id: 1234).should be_true
  end

  it "removes an order" do
    Spree::Chimpy::Config.preferred_store_id = "super-store"
    api.should_receive(:ecomm_order_del).with('super-store',123).and_return(true)

    interface.remove(123).should be_true
  end
end

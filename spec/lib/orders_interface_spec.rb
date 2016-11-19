require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { described_class.new }

  let(:store_api) { double(:store_api) }
  let(:order_api) { double(:order_api) }

  let(:order) { create(:order) }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
  end

  context "adding an order" do
    it "calls the order upserter" do

      expect_any_instance_of(Spree::Chimpy::Interface::OrderUpserter).to receive(:upsert)
      interface.add(order)
    end
  end

  it "removes an order" do
    expect(store_api).to receive(:orders)
      .with(order.number)
      .and_return(order_api)

    expect(order_api).to receive(:delete)
      .and_return(true)

    expect(interface.remove(order)).to be_truthy
  end
end


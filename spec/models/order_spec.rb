require 'spec_helper'

describe Spree::Order do

  let(:key) { 'e025fd58df5b66ebd5a709d3fcf6e600-us8' }

  it "has a source" do
    order = Spree::Order.new
    expect(order).to respond_to(:source)
  end

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.key = nil

      @completed_order     = create(:completed_order_with_totals)
      @not_completed_order = create(:order)

      Spree::Chimpy::Config.key = key
    end

    subject { Spree::Chimpy }

    it "doesnt update when order is not completed" do
      expect(subject).to_not receive(:enqueue)
      @not_completed_order.update!
    end

    it "updates when order is completed" do
      expect(subject).to receive(:enqueue).with(:order, @completed_order)
      @completed_order.update!
    end

    it "sync when order is completed" do
      expect(subject).to receive(:enqueue).with(:order, @completed_order).twice
      @completed_order.cancel!
    end
  end
end

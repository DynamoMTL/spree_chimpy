require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    expect(order).to respond_to(:source)
  end

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.key = nil

      @completed_order     = FactoryGirl.build(:completed_order_with_totals)
      @not_completed_order = FactoryGirl.build(:order)

      Spree::Chimpy::Config.key = '1234'
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
      expect(subject).to receive(:enqueue).with(:order, @completed_order)
      @completed_order.cancel!
    end
  end
end

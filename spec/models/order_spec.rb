require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    order.should respond_to(:source)
  end

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.preferred_key = nil

      @completed_order     = FactoryGirl.build(:completed_order_with_totals)
      @not_completed_order = FactoryGirl.build(:order)

      Spree::Chimpy::Config.preferred_key = '1234'
    end

    it "doesnt update when order is not completed" do
      Spree::Chimpy::OrderNotice.should_not_receive(:new)
      @not_completed_order.update!
    end

    it "updates when order is completed" do
      Spree::Chimpy::OrderNotice.should_receive(:new).with(@completed_order)
      @completed_order.update!
    end

    it "sync when order is completed" do
      Spree::Chimpy::OrderNotice.should_receive(:new).with(@completed_order).twice
      @completed_order.cancel!
    end
  end
end

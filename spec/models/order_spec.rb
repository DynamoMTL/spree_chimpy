require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    order.should respond_to(:source)
  end

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.key = nil

      @completed_order     = FactoryGirl.create(:completed_order_with_totals)
      @not_completed_order = FactoryGirl.create(:order)

      Spree::Chimpy::Config.key = '1234'
    end

    it "doesnt update when order is not completed" do
      Spree::Chimpy.should_not_receive(:enqueue)
      @not_completed_order.update!
    end

    it "updates when order is completed" do
      Spree::Chimpy.should_receive(:enqueue).with(:order, @completed_order)
      @completed_order.update!
    end
    
  end
end

require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    order.should respond_to(:source)
  end

  let(:completed_order) { FactoryGirl.create(:completed_order_with_totals) }
  let(:not_completed_order) { FactoryGirl.create(:order) }

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.key = nil
      Spree::Chimpy::Config.key = '1234'
    end

    it "doesnt update when order is not completed" do
      Spree::Chimpy.should_not_receive(:enqueue)
      not_completed_order.update!
    end

    it "doesnt update when order is complete but not shipped" do
      completed_order.stub(:shipped? => false)
      Spree::Chimpy.should_not_receive(:enqueue)
      completed_order.update!
    end


    it "updates when order is completed and shipped" do
      completed_order.stub(:shipped? => true)
      Spree::Chimpy.should_receive(:enqueue).with(:order, completed_order)
      completed_order.update!
    end
    
  end
end

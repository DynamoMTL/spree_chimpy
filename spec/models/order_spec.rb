require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    expect(order).to respond_to(:source)
  end

  let(:completed_order) { FactoryGirl.create(:completed_order_with_totals) }
  let(:not_completed_order) { FactoryGirl.create(:order) }

  context "notifying mail chimp" do
    before do
      Spree::Chimpy::Config.key = nil
      Spree::Chimpy::Config.key = '1234'
    end

    it "doesnt update when order is not completed" do
      expect(Spree::Chimpy).not_to receive(:enqueue)
      not_completed_order.update!
    end

    it "doesnt update when order is complete but not shipped" do
      allow(completed_order).to receive_messages(:shipped? => false)
      expect(Spree::Chimpy).not_to receive(:enqueue)
      completed_order.update!
    end


    it "updates when order is completed and shipped" do
      allow(completed_order).to receive_messages(:shipped? => true)
      expect(Spree::Chimpy).to receive(:enqueue).with(:order, completed_order)
      completed_order.update!
    end
    
  end
end

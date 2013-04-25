require 'spec_helper'

describe Spree::Hominid::OrderNotice do
  context "syncing order" do
    let(:notice)    { Spree::Hominid::OrderNotice.new(order) }
    let(:interface) { mock(:interface) }

    before do
      Spree::Hominid::Config.preferred_key = nil
      Spree::Hominid::Config.stub(orders: interface)
    end

    context "canceled" do
      let(:order) { FactoryGirl.create(:completed_order_with_totals, state: 'canceled')}

      it "removes order" do
        interface.should_receive(:remove).with(order.number)

        Spree::Hominid::Config.preferred_key = '1234'
        Spree::Hominid::OrderNotice.new(order)
      end
    end

    context "completed" do
      let(:order) { FactoryGirl.create(:completed_order_with_totals)}

      context "order already exists in mail chimp" do
        it "removes order first" do
          interface.should_receive(:remove).with(order.number)
          interface.should_receive(:add).with(order)

          Spree::Hominid::Config.preferred_key = '1234'
          Spree::Hominid::OrderNotice.new(order)
        end
      end

      context "order does not exist in mail chimp" do
        it "adds order" do
          interface.should_receive(:remove).with(order.number).and_raise('oopsie. not found')
          interface.should_receive(:add).with(order)

          Spree::Hominid::Config.preferred_key = '1234'
          Spree::Hominid::OrderNotice.new(order)
        end
      end
    end
  end
end

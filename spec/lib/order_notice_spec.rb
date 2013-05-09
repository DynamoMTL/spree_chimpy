require 'spec_helper'

describe Spree::Chimpy::OrderNotice do
  context "syncing order" do
    let(:notice)    { Spree::Chimpy::OrderNotice.new(order) }
    let(:interface) { mock(:interface) }

    before do
      Spree::Chimpy::Config.preferred_key = nil
      Spree::Chimpy::Config.stub(orders: interface)
    end

    context "canceled" do
      let(:order) { FactoryGirl.create(:completed_order_with_totals, state: 'canceled')}

      it "removes order" do
        interface.should_receive(:remove).with(order.number)

        Spree::Chimpy::Config.preferred_key = '1234'
        Spree::Chimpy::OrderNotice.new(order)
      end
    end

    context "completed" do
      let(:order) { FactoryGirl.create(:completed_order_with_totals)}

      context "order already exists in mail chimp" do
        it "removes order first" do
          interface.should_receive(:remove).with(order.number)
          interface.should_receive(:add).with(order_options(order))

          Spree::Chimpy::Config.preferred_key = '1234'
          Spree::Chimpy::OrderNotice.new(order)
        end
      end

      context "order does not exist in mail chimp" do
        it "adds order" do
          interface.should_receive(:remove).with(order.number).and_raise('oopsie. not found')
          interface.should_receive(:add).with(order_options(order))

          Spree::Chimpy::Config.preferred_key = '1234'
          Spree::Chimpy::OrderNotice.new(order)
        end
      end

      context "order has a source" do
        let(:order) { FactoryGirl.create(:completed_order_with_totals)}

        before do
          order.create_source
          interface.should_receive(:remove).with(order.number).and_raise('oopsie. not found')
          Spree::Chimpy::Config.preferred_key = '1234'
        end

        it "uses campaign id" do
          order.source.campaign_id = 123
          interface.should_receive(:add).with(hash_including(campaign_id: 123))
          Spree::Chimpy::OrderNotice.new(order)
        end

        it "uses email id" do
          order.source.email_id = 123
          interface.should_receive(:add).with(hash_including(email_id: 123))
          Spree::Chimpy::OrderNotice.new(order)
        end
      end

      def order_options(order)
        {
          id:         order.number,
          email:      order.email,
          total:      order.total,
          order_date: order.completed_at,
          shipping:   order.ship_total,
          tax:        order.tax_total,
          store_name: Spree::Config.preferred_site_name,
          store_id:   Spree::Chimpy::Config.preferred_store_id,
          items:      order.line_items.map do |line|
            variant = line.variant

            {product_id:   variant.id,
             sku:          variant.sku,
             product_name: variant.name,
             cost:         variant.cost_price,
             qty:          line.quantity}
          end
        }
      end
    end
  end
end

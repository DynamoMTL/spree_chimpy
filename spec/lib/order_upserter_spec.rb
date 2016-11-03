require 'spec_helper'

describe Spree::Chimpy::Interface::OrderUpserter do
  let(:store_id)  { "super-store" }
  let(:store_api) { double(:store_api) }
  let(:order_api) { double(:order_api) }
  let(:orders_api) { double(:orders_api) }
  let(:customer_id) { "customer_123" }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
  end

  def create_order(options={})
    user  = create(:user, email: options[:email])

    # we need to have a saved order in order to have a non-nil order number
    # we need to stub :notify_mail_chimp otherwise sync will be called on the order on update!
    allow_any_instance_of(Spree::Order).to receive(:notify_mail_chimp).and_return(true)
    order = create(:completed_order_with_totals, user: user, email: options[:email])
    order.source = Spree::Chimpy::OrderSource.new(email_id: options[:email_id], campaign_id: options[:campaign_id])
    order.save
    order
  end

  describe "#upsert" do
    let(:order) { create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com') }
    let(:interface) { described_class.new(order) }
    let(:customer_upserter) { double('cusotmer_upserter') }

    def check_hash(h, expected_customer_id)
      body = h[:body]
      expect(body[:id]).to eq order.number

      expect(body[:campaign_id]).to eq '1234'
      expect(body[:order_total]).to eq order.total.to_f
      expect(body[:customer]).to eq({id: expected_customer_id})

      line = body[:lines].first
      item = order.line_items.first
      expect(line[:id]).to eq "line_item_#{item.id}"
      expect(line[:product_id]).to eq item.variant.product_id.to_s
      expect(line[:product_variant_id]).to eq item.variant_id.to_s
      expect(line[:price]).to eq item.variant.price.to_f
      expect(line[:quantity]).to eq item.quantity
    end

    before(:each) do
      allow(store_api).to receive(:orders)
        .and_return(orders_api)
      allow(store_api).to receive(:orders)
        .with(anything)
        .and_return(order_api)
      allow(Spree::Chimpy::Interface::Products).to receive(:ensure_products)
      allow(Spree::Chimpy::Interface::CustomerUpserter).to receive(:new).with(order) { customer_upserter }
      allow(customer_upserter).to receive(:ensure_customer) { customer_id }
    end

    it "calls ensure_products" do
      allow(interface).to receive(:perform_upsert)
      expect(Spree::Chimpy::Interface::Products).to receive(:ensure_products).with(order)
      interface.upsert
    end

    it "ensures the customer exists and uses that ID" do
      expect(customer_upserter).to receive(:ensure_customer)
        .and_return("customer_1")

      expect(interface).to receive(:find_and_update_order) do |h|
        expect(h[:customer][:id]).to eq "customer_1"
      end

      interface.upsert
    end

    it "does not perform the order upsert if no customer_id exists" do
      expect(customer_upserter).to receive(:ensure_customer)
        .and_return(nil)

      expect(interface).to_not receive(:perform_upsert)

      interface.upsert
    end

    context "when order already exists" do
      before(:each) do
        allow(order_api).to receive(:retrieve)
          .and_return({ "id" => order.number })
      end

      it "updates a found order" do
        expect(order_api).to receive(:update) do |h|
          check_hash(h, customer_id)
        end
        interface.upsert
      end
    end

    context "when order is not found" do
      before(:each) do
        allow(order_api).to receive(:retrieve)
          .and_raise(Gibbon::MailChimpError)
      end

      it "creates order" do
        expect(orders_api).to receive(:create) do |h|
          check_hash(h, customer_id)
        end
        interface.upsert
      end
    end
  end
end

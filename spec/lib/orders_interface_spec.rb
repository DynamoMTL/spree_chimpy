require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { described_class.new }
  let(:api)       { double(:api) }
  let(:list)      { double(:list) }
  let(:key)       { '857e2096b21e5eb385b9dce2add84434-us14' }

  let(:store_id)  { "super-store" }
  let(:store_api) { double(:store_api) }
  let(:order_api) { double(:order_api) }
  let(:orders_api) { double(:orders_api) }
  let(:product_api) { double(:product_api) }
  let(:customer_api) { double(:customer_api) }
  let(:customers_api) { double(:customers_api) }

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

  before do
    Spree::Chimpy::Config.key = key
    Spree::Chimpy::Config.store_id = store_id
    Spree::Chimpy::Config.subscribe_to_list = true
    Spree::Chimpy.stub(list: list)

    Gibbon::Request.stub(:new).with(api_key: key, timeout: 60 ).and_return(api)
    ecommerce_api = double()
    allow(api).to receive(:ecommerce).and_return(ecommerce_api)
    allow(ecommerce_api).to receive(:stores).with(store_id).and_return(store_api)

  end

  context "adding an order" do
    before(:each) do
      allow(interface).to receive(:ensure_products)
      allow(interface).to receive(:upsert_order)
      allow(interface).to receive(:customer_id_from_eid).with("id-abcd").and_return('customer_123')
    end

    it "ensures products" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      expect(interface).to receive(:ensure_products)
        .with(order)

      interface.add(order)
    end

    it "ensures the customer exists" do
      order = create_order(email_id: 'id-abcd', email: 'other@home.com')

      expect(interface).to receive(:ensure_customer)
        .with(order)
        .and_return("customer_1")

      interface.add(order)
    end

    it "sync when member info matches" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')

      expect(interface).to receive(:upsert_order)
        .with(order, "customer_123")

      interface.add(order)
    end
  end

  it "removes an order" do
    order = create_order(email: 'foo@example.com')
    expect(store_api).to receive(:orders)
      .with(order.number)
      .and_return(order_api)

    expect(order_api).to receive(:delete)
      .and_return(true)

    expect(interface.remove(order)).to be_truthy
  end

  describe "private #ensure_products" do
    let(:order) { create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com') }
    let(:first_product_api) { double(:first_product_api) }

    context "when product does not exist" do
      before(:each) do
        create(:taxon)

        allow(store_api).to receive(:products)
          .and_return(first_product_api, product_api, product_api, product_api, product_api)

        allow(product_api).to receive(:create)
        allow(interface).to receive(:product_exists_in_mailchimp?).and_return(false)
      end

      it "creates the missing product and variants" do
        expect(first_product_api).to receive(:create) do |h|
          product = order.line_items.first.variant.product
          expect(h[:body]).to include({
            id: product.id.to_s,
            title: product.name,
            handle: product.slug,
          })
          expect(h[:body][:url]).to include("/products/#{product.slug}")
          v = h[:body][:variants].first
          expect(v[:id]).to eq product.master.id.to_s
          expect(v[:title]).to eq product.master.name
          expect(v[:sku]).to eq product.master.sku
          expect(v[:price]).to eq product.master.price
        end

        interface.send(:ensure_products, order)
      end
    end

    context "when product already exists" do
      before(:each) do
        allow(interface).to receive(:product_exists_in_mailchimp?).and_return(true)
        allow(store_api).to receive(:products).and_return(product_api)
      end

      it "updates each variant" do

        order.line_items.each do |item|
          variant_api = double('variant_api')
          allow(product_api).to receive(:variants).with(item.variant_id).and_return(variant_api)

          expect(variant_api).to receive(:upsert) do |h|
            product = item.variant.product
            expect(h[:body][:url]).to include("/products/#{product.slug}")
            expect(h[:body][:title]).to eq item.variant.name
            expect(h[:body][:sku]).to eq item.variant.sku
            expect(h[:body][:price]).to eq item.variant.price
            expect(h[:body][:id]).to be_nil
          end
        end

        interface.send(:ensure_products, order)
      end
    end
  end

  describe "private #ensure_customer" do
    let(:order) { create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com') }

    #TODO: Changed from skips sync when mismatch -
    # Updated logic takes the customer attached to the mc_eid regardless of email matching order
    # When no customer exists for that mc_eid, it will create the customer for the order email
    # Should this remain due to v3.0 updates?
    it "retrieves the customer id from the order source if it exists" do
      allow(interface).to receive(:customer_id_from_eid)
        .with('id-abcd')
        .and_return("customer_999")

      expect(interface.send(:ensure_customer, order)).to eq "customer_999"
    end

    it "upserts the customer when not found by order source" do
      allow(interface).to receive(:customer_id_from_eid)
        .with('id-abcd')
        .and_return(nil)

      allow(interface).to receive(:upsert_customer)
        .with(order)
        .and_return("customer_998")

      expect(interface.send(:ensure_customer, order)).to eq "customer_998"
    end
  end

  describe "private #upsert_customer" do
    let(:order) { create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com') }
    before(:each) do
      allow(store_api).to receive(:customers)
        .and_return(customers_api)
      allow(store_api).to receive(:customers)
        .with("customer_#{order.user_id}")
        .and_return(customer_api)
    end

    it "retrieves based on the customer_id" do
      expect(customer_api).to receive(:retrieve)
        .with(params: { "fields" => "id,email_address"})
        .and_return({ "id" => "customer_#{order.user_id}", "email_address" => order.email})

      customer_id = interface.send(:upsert_customer, order)
      expect(customer_id).to eq "customer_#{order.user_id}"
    end

    it "creates the customer when lookup fails" do
      allow(customer_api).to receive(:retrieve)
        .and_raise(Gibbon::MailChimpError)

      expect(customers_api).to receive(:create)
        .with(:body => {
          id: "customer_#{order.user_id}",
          email_address: order.email.downcase,
          opt_in_status: true
          })

      customer_id = interface.send(:upsert_customer, order)
      expect(customer_id).to eq "customer_#{order.user_id}"
    end

    it "honors subscribe_to_list settings" do
      Spree::Chimpy::Config.subscribe_to_list = false

      allow(customer_api).to receive(:retrieve)
        .and_raise(Gibbon::MailChimpError)

      expect(customers_api).to receive(:create) do |h|
        expect(h[:body][:opt_in_status]).to eq false
      end
      interface.send(:upsert_customer, order)
    end
  end

  describe "private #customer_id_from_eid" do
    let(:email) { "user@example.com" }
    before(:each) do
      allow(store_api).to receive(:customers) { customers_api }
    end

    it "returns based on the mailchimp email address when found" do
      allow(list).to receive(:email_for_id).with("id-abcd")
        .and_return(email)

      expect(customers_api).to receive(:retrieve)
        .with(params: { "fields" => "customers.id", "email_address" => email})
        .and_return({ "customers" => [{"id" => "customer_xyz"}] })

      id = interface.send(:customer_id_from_eid, "id-abcd")
      expect(id).to eq "customer_xyz"
    end

    it "is nil if email for id not found" do
      allow(list).to receive(:email_for_id).with("id-abcd")
        .and_return(nil)

      expect(interface.send(:customer_id_from_eid, "id-abcd")).to be_nil
    end

    it "is nil if email not found among customers" do
      allow(list).to receive(:email_for_id)
        .with("id-abcd")
        .and_return(email)

      expect(customers_api).to receive(:retrieve)
        .and_raise(Gibbon::MailChimpError)

      expect(interface.send(:customer_id_from_eid, "id-abcd")).to be_nil
    end
  end

  describe "private #upsert_order" do
    let(:order) { create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com') }

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
    end

    context "when order already exists" do
      before(:each) do
        allow(order_api).to receive(:retrieve)
          .and_return({ "id" => order.number })
      end

      it "updates a found order" do
        expect(order_api).to receive(:update) do |h|
          check_hash(h, "customer_123")
        end
        interface.send(:upsert_order, order, "customer_123")
      end
    end

    context "when order is not found" do

      before(:each) do
        allow(order_api).to receive(:retrieve)
          .and_raise(Gibbon::MailChimpError)
      end

      it "creates order" do
        expect(orders_api).to receive(:create) do |h|
          check_hash(h, "customer_123")
        end
        interface.send(:upsert_order, order, "customer_123")
      end

      it "honors a customer_id that does not match the order" do
        expect(orders_api).to receive(:create) do |h|
          check_hash(h, "customer_124")
        end
        interface.send(:upsert_order, order, "customer_124")
      end
    end
  end
end


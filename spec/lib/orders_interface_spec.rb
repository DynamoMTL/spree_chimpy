require 'spec_helper'

describe Spree::Chimpy::Interface::Orders do
  let(:interface) { described_class.new }
  let(:api)       { double(:api) }
  let(:list)      { double(:list) }
  let(:key)       { '857e2096b21e5eb385b9dce2add84434-us14' }

  let(:store_id)  { "super-store" }
  let(:store_api) { double(:store_api) }
  let(:order_api) { double(:order_api) }
  let(:product_api) { double(:product_api) }

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
      allow(list).to receive(:email_for_id).with('id-abcd').and_return('User@Example.com')
      allow(store_api).to receive(:orders).and_return(order_api)
      allow(interface).to receive(:ensure_products)
    end

    it "ensures products" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      expect(interface).to receive(:ensure_products).with(order)
      allow(order_api).to receive(:upsert)
      interface.add(order)
    end

    it "sync when member info matches" do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')

      expect(store_api).to receive(:orders).with(order.number).and_return(order_api)
      expect(order_api).to receive(:upsert) do |h|
        body = h[:body]
        expect(body[:id]).to eq order.number
        expect(body[:email_id]).to eq 'id-abcd'
        expect(body[:campaign_id]).to eq '1234'
        expect(body[:order_total]).to eq order.total.to_f
        expect(body[:customer]).to eq({
          id: "customer_#{order.user.id}",
          email_address: order.email.downcase,
          opt_in_status: true
        })

        line = body[:lines].first
        item = order.line_items.first
        expect(line[:id]).to eq "line_item_#{item.id}"
        expect(line[:product_id]).to eq item.variant.product_id
        expect(line[:product_variant_id]).to eq item.variant_id
        expect(line[:price]).to eq item.variant.price.to_f
        expect(line[:quantity]).to eq item.quantity
      end

      interface.add(order)
    end

    it "skips mismatches member" do
      order = create_order(email_id: 'id-abcd', email: 'other@home.com')
      expect(store_api).to receive(:orders).with(order.number).and_return(order_api)
      expect(order_api).to receive(:upsert) do |h|
        expect(h[:body][:id]).to eq order.number
        expect(h[:body][:email_id]).to be_nil
        expect(h[:body][:campaign_id]).to be_nil
      end

      interface.add(order)
    end

    it 'skips subscription if manually turned off in config' do
      order = create_order(email_id: 'id-abcd', campaign_id: '1234', email: 'user@example.com')
      Spree::Chimpy::Config.subscribe_to_list = false
      expect(store_api).to receive(:orders).with(order.number).and_return(order_api)

      expect(order_api).to receive(:upsert) do |h|
        expect(h[:body][:id]).to eq order.number
        expect(h[:body][:email_id]).to eq 'id-abcd'
        expect(h[:body][:campaign_id]).to eq '1234'
        expect(h[:body][:customer][:id]).to eq "customer_#{order.user.id}"
        expect(h[:body][:customer][:email_address]).to eq 'user@example.com'
        expect(h[:body][:customer][:opt_in_status]).to eq false
      end

      interface.add(order)
    end
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

  it "removes an order" do
    order = create_order(email: 'foo@example.com')
    expect(store_api).to receive(:orders).with(order.number).and_return(order_api)

    expect(order_api).to receive(:delete).and_return(true)
    expect(interface.remove(order)).to be_truthy
  end
end

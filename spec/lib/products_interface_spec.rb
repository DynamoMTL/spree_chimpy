require 'spec_helper'

describe Spree::Chimpy::Interface::Products do
  let(:store_api) { double(:store_api) }
  let(:customer_id) { "customer_123" }

  let(:product_api) { double(:product_api) }
  let(:products_api) { double(:products_api) }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
    allow(store_api).to receive(:products) { products_api }
  end

  describe "ensure_products" do
    let(:order) {
      allow_any_instance_of(Spree::Order).to receive(:notify_mail_chimp).and_return(true)
      create(:completed_order_with_totals)
    }

    it "ensures each product in the order" do
      order.line_items.each do |line_item|
        interface = double('products')
        described_class.stub(:new).with(line_item.variant) { interface }
        expect(interface).to receive(:ensure_product)
      end
      described_class.ensure_products(order)
    end
  end

  describe "ensure_product" do
    let(:variant) { create(:variant) }
    let(:interface) { described_class.new(variant) }

    context "when product does not exist" do
      before(:each) do
        create(:taxon)
        allow(product_api).to receive(:create)
        allow(interface).to receive(:product_exists_in_mailchimp?).and_return(false)
      end

      it "creates the missing product and variants" do
        expect(products_api).to receive(:create) do |h|
          product = variant.product
          expect(h[:body]).to include({
            id: product.id.to_s,
            title: product.name,
            handle: product.slug,
          })
          expect(h[:body][:url]).to include("/products/#{product.slug}")
          expect(h[:body][:variants].count).to eq 1
          v = h[:body][:variants].first
          expect(v[:id]).to eq variant.id.to_s
          expect(v[:title]).to eq product.master.name
          expect(v[:sku]).to eq variant.sku
          expect(v[:price]).to eq product.master.price
        end

        interface.ensure_product
      end
    end

    context "when product already exists" do
      before(:each) do
        allow(interface).to receive(:product_exists_in_mailchimp?).and_return(true)
        allow(store_api).to receive(:products).and_return(product_api)
      end

      it "updates the variant" do
        variant_api = double('variant_api')
        allow(product_api).to receive(:variants).with(variant.id).and_return(variant_api)

        expect(variant_api).to receive(:upsert) do |h|
          product = variant.product
          expect(h[:body][:url]).to include("/products/#{product.slug}")
          expect(h[:body][:title]).to eq variant.name
          expect(h[:body][:sku]).to eq variant.sku
          expect(h[:body][:price]).to eq variant.price
          expect(h[:body][:id]).to be_nil
        end

        interface.ensure_product
      end
    end
  end
end
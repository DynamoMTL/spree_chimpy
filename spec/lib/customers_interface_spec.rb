require 'spec_helper'

describe Spree::Chimpy::Interface::CustomerUpserter do
  let(:store_api) { double(:store_api) }
  let(:customer_api) { double(:customer_api) }
  let(:customers_api) { double(:customers_api) }
  let(:email_id) { "id-abcd" }
  let(:campaign_id) { "campaign-1" }

  let(:order) {
    allow_any_instance_of(Spree::Order).to receive(:notify_mail_chimp).and_return(true)
    order = create(:completed_order_with_totals)
    order.source = Spree::Chimpy::OrderSource.new(email_id: email_id, campaign_id: campaign_id)
    order.save
    order
  }
  let(:interface) { described_class.new(order) }
  let(:list)      { double(:list) }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
    Spree::Chimpy.stub(list: list)
    Spree::Chimpy::Config.subscribe_to_list = true
  end

  describe ".ensure_customers" do

    #TODO: Changed from skips sync when mismatch -
    # Updated logic takes the customer attached to the mc_eid regardless of email matching order
    # When no customer exists for that mc_eid, it will create the customer for the order email
    # Should this remain due to v3.0 updates?
    it "retrieves the customer id from the order source if it exists" do
      order.source = Spree::Chimpy::OrderSource.new(email_id: 'id-abcd')
      order.save

      allow(interface).to receive(:customer_id_from_eid)
        .with('id-abcd')
        .and_return("customer_999")

      expect(interface.ensure_customer).to eq "customer_999"
    end

    context "when no customer from order source" do
      before(:each) do
        allow(interface).to receive(:customer_id_from_eid)
          .with('id-abcd')
          .and_return(nil)
      end

      it "upserts the customer" do
        allow(interface).to receive(:upsert_customer) { "customer_998" }

        expect(interface.ensure_customer).to eq "customer_998"
      end

      it "returns nil if guest checkout" do
        order.user_id = nil
        expect(interface.ensure_customer).to be_nil
      end
    end
  end

  describe "#upsert_customer" do

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

      customer_id = interface.send(:upsert_customer)
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

      customer_id = interface.send(:upsert_customer)
      expect(customer_id).to eq "customer_#{order.user_id}"
    end

    it "honors subscribe_to_list settings" do
      Spree::Chimpy::Config.subscribe_to_list = false

      allow(customer_api).to receive(:retrieve)
        .and_raise(Gibbon::MailChimpError)

      expect(customers_api).to receive(:create) do |h|
        expect(h[:body][:opt_in_status]).to eq false
      end
      interface.send(:upsert_customer)
    end
  end

  describe "#customer_id_from_eid" do
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

      id = interface.customer_id_from_eid("id-abcd")
      expect(id).to eq "customer_xyz"
    end

    it "is nil if email for id not found" do
      allow(list).to receive(:email_for_id).with("id-abcd")
        .and_return(nil)

      expect(interface.customer_id_from_eid("id-abcd")).to be_nil
    end

    it "is nil if email not found among customers" do
      allow(list).to receive(:email_for_id)
        .with("id-abcd")
        .and_return(email)

      expect(customers_api).to receive(:retrieve)
        .and_raise(Gibbon::MailChimpError)

      expect(interface.customer_id_from_eid("id-abcd")).to be_nil
    end
  end
end
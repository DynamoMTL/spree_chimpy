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

  describe ".ensure_customer" do
    # Cascading lookup of eid, own customer_id, email address, upsert
    it "first tries the eid lookup" do
      expect(interface).
        to receive(:lookup_customer_id_from_eid).and_return(:foobar)
      expect(interface.ensure_customer).to eq :foobar
    end

    describe "eid fails" do
      before :each do
        expect(interface).
          to receive(:lookup_customer_id_from_eid).and_return(nil)
      end

      it "then tries the customer_id lookup" do
        expect(interface).
          to receive(:lookup_customer_id_from_user_id).and_return(:foobar)
        expect(interface.ensure_customer).to eq :foobar
      end

      describe "customer_id lookup fails" do
        before :each do
          expect(interface).
            to receive(:lookup_customer_id_from_user_id).and_return(nil)
        end

        it "then tries the email address lookup" do
          expect(interface).to \
            receive(:lookup_customer_id_from_email_address).and_return(:foobar)
          expect(interface.ensure_customer).to eq :foobar
        end

        describe "email address lookup fails" do
          before :each do
            expect(interface).to \
              receive(:lookup_customer_id_from_email_address).and_return(nil)
          end

          it "then upserts the customer" do
            expect(interface).
              to receive(:upsert_customer).and_return(:foobar)
            expect(interface.ensure_customer).to eq :foobar
          end
        end
      end
    end
  end

  describe "#mailchimp_customer_id" do
    it "picks customer_* for orders with customers" do
      expect(interface.send(:mailchimp_customer_id)).
        to eq "customer_#{order.user_id}"
    end

    it "picks guest_* for guest orders" do
      order.user = nil
      expect(interface.send(:mailchimp_customer_id)).
        to start_with("guest_")
    end
  end

  describe "#upsert_customer" do
    let(:customer_id) { "customer_#{order.user_id}" }

    before :each do
      allow(store_api).to receive(:customers).with(anything).
        and_return customers_api
      allow(customers_api).to receive(:upsert).and_return(nil)
    end

    it "upserts the customer" do
      expect(interface.send(:upsert_customer)).to eq "customer_#{order.user_id}"
    end

    it "sets first_name and last_name" do
      expect(customers_api).to receive(:upsert) do |h|
        body = h[:body]
        expect(body[:first_name]).to be_present
        expect(body[:last_name]).to be_present
      end

      interface.send :upsert_customer
    end

    it "picks the id from #mailchimp_customer_id" do
      expect(interface).to receive(:mailchimp_customer_id).and_return "foobar"

      expect(interface.send(:upsert_customer)).to eq "foobar"
    end

    it "honors subscribe_to_list settings" do
      Spree::Chimpy::Config.subscribe_to_list = false

      expect(customers_api).to receive(:upsert) do |h|
        expect(h[:body][:opt_in_status]).to eq false
      end

      interface.send(:upsert_customer)
    end
  end

  describe "#lookup_customer_id_from_eid" do
    let(:email) { "user@example.com" }
    before(:each) do
      allow(store_api).to receive(:customers) { customers_api }
    end

    it "does not lookup and returns nil if there is no source" do
      expect(store_api).to_not receive(:customers)
      interface.order.source = nil
      expect(interface.lookup_customer_id_from_eid).to be_nil
    end

    describe "with an email source" do
      it "is nil if email for id not found" do
        allow(list).to receive(:email_for_id).with(email_id).and_return(nil)

        expect(interface.lookup_customer_id_from_eid).to be_nil
      end

      describe "with a found email_id" do
        before :each do
          allow(list).to receive(:email_for_id).with(email_id).and_return(email)
        end

        it "is nil if email not found among customers" do
          expect(customers_api).to receive(:retrieve).
            and_raise(Gibbon::MailChimpError)

          expect(interface.lookup_customer_id_from_eid).to be_nil
        end

        it "returns the customer_id if found" do
          expect(customers_api).to receive(:retrieve).and_return \
            "customers" => [{ "id" => "customer_123" }]
          expect(interface.lookup_customer_id_from_eid).to eq "customer_123"
        end
      end
    end
  end
end

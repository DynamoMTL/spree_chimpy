require 'spec_helper'

describe Spree.user_class do
  context "data accessor methods" do
    let(:shipping_address) { create(:ship_address)}

    context "for registered user" do
      let!(:registered_user) { create(:user, enrolled: true) }
      before do
        Spree::Chimpy::Config.key = nil
        @completed_order     = FactoryGirl.create(:completed_order_with_totals, user: registered_user, ship_address: shipping_address)
        Spree::Chimpy::Config.key = '1234'
      end
      
      it "accesses the shipping address and order information" do
        expect(registered_user.first_name).to eq 'John'
        expect(registered_user.last_name).to eq 'Doe'
        expect(registered_user.country).to eq shipping_address.country.name
        expect(registered_user.city).to eq 'Herndon'

        expect(registered_user.number_of_orders).to eq 1
        expect(registered_user.total_orders_amount).to eq @completed_order.item_total * Spree::Chimpy::Config.to_gbp_rates['USD']
        expect(registered_user.average_basket_size).to eq @completed_order.item_total * Spree::Chimpy::Config.to_gbp_rates['USD']
      end

    end

    context "for guest user" do
      let!(:guest_user) { create(:user, email: 'john@doe.com', enrolled: false) }
      before do
        Spree::Chimpy::Config.key = nil
        @completed_order     = FactoryGirl.create(:completed_order_with_totals, user: nil, email: 'john@doe.com')
        Spree::Chimpy::Config.key = '1234'
      end
      
      it "accesses the shipping address and order information" do
        expect(guest_user.first_name).to eq 'John'
        expect(guest_user.last_name).to eq 'Doe'
        expect(guest_user.country).to eq shipping_address.country.name
        expect(guest_user.city).to eq 'Herndon'

        expect(guest_user.number_of_orders).to eq 1
        expect(guest_user.total_orders_amount).to eq @completed_order.item_total * Spree::Chimpy::Config.to_gbp_rates['USD']
        expect(guest_user.average_basket_size).to eq @completed_order.item_total * Spree::Chimpy::Config.to_gbp_rates['USD']
      end
    end
  end

  context "syncing with mail chimp" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      expect(Spree::Chimpy::Subscription).to receive(:new).at_least(1).and_return(subscription)
      @user = FactoryGirl.create(:user)
    end

    it "submits after destroy" do
      expect(subscription).to receive(:unsubscribe)

      @user.destroy
    end
  end

  it "doesnt subscribe by default" do
    expect(Spree.user_class.new.subscribed).to eq(nil)
  end


end

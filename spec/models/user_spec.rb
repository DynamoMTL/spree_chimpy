require 'spec_helper'

describe Spree.user_class do
  context "data accessor methods" do
    let(:shipping_address) { create(:ship_address)}

    context "for registered user" do
      let!(:registered_user) { create(:user, enrolled: true) }
      let!(:complete_order) { create(:completed_order_with_totals, user: registered_user, ship_address: shipping_address) }
      
      it "accesses the shipping address and order information" do
        expect(registered_user.first_name).to eq 'John'
        expect(registered_user.last_name).to eq 'Doe'
        expect(registered_user.country).to eq shipping_address.country.name
        expect(registered_user.city).to eq 'Herndon'

        expect(registered_user.number_of_orders).to eq 1
        expect(registered_user.total_orders_amount).to eq complete_order.item_total
        expect(registered_user.average_basket_size).to eq complete_order.item_total
      end

    end

    context "for guest user" do
      let!(:guest_user) { create(:user, email: 'john@doe.com', enrolled: false) }
      let!(:complete_order) { create(:completed_order_with_totals, user: nil, email: 'john@doe.com') }
      
      it "accesses the shipping address and order information" do
        expect(guest_user.first_name).to eq 'John'
        expect(guest_user.last_name).to eq 'Doe'
        expect(guest_user.country).to eq shipping_address.country.name
        expect(guest_user.city).to eq 'Herndon'

        expect(guest_user.number_of_orders).to eq 1
        expect(guest_user.total_orders_amount).to eq complete_order.item_total
        expect(guest_user.average_basket_size).to eq complete_order.item_total
      end
    end
  end

  context "syncing with mail chimp" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      Spree::Chimpy::Subscription.should_receive(:new).at_least(1).and_return(subscription)
      @user = FactoryGirl.create(:user)
    end

    it "submits after destroy" do
      subscription.should_receive(:unsubscribe)

      @user.destroy
    end
  end

  it "doesnt subscribe by default" do
    Spree.user_class.new.subscribed.should == nil
  end


  context "Class Methods" do
    let(:subject) { Spree.user_class }
    before do
      FactoryGirl.create(:user, email: 'bob@sponge.net', subscribed: true)
    end

    it "#customer_has_subscribed?" do
      expect(subject.customer_has_subscribed?('bob@sponge.net')).to be_true
    end
  end

end

require 'spec_helper'

describe Spree::Chimpy::Subscription do

  context "Mailchimp enabled" do
    let(:interface)    { double(:interface) }

    before do
      Spree::Chimpy::Config.list_name  = 'Members'
      Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email}
      allow(Spree::Chimpy).to receive_messages(list: interface)
      # Delayed::Worker.delay_jobs = false # enable if test_failures
      allow(Spree::Chimpy::Config).to receive_messages(key: '1234')
    end

    context "subscribes users" do
      let(:user)         { FactoryGirl.create(:user, subscribed: false) }
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before do
        Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "successfully" do
        expect(interface).to receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'}, customer: true)
        subscription.subscribe
      end

    end

    context "who are not enrolled" do
      let(:subscriber)   { FactoryGirl.create(:user, enrolled: false) }
      let(:subscription) { Spree::Chimpy::Subscription.new(subscriber) }

      it "subscribes subscribers" do
        expect(interface).to receive(:subscribe).with(subscriber.email, {}, customer: false)
        expect(interface).not_to receive(:segment)
        subscription.subscribe

        expect(subscriber.subscribed).to eq(true)
      end

      it "subscribes subscribers" do
        expect(interface).to receive(:subscribe).with(subscriber.email, {}, customer: false)
        expect(interface).not_to receive(:segment)

        subscriber.subscribed = true
        subscriber.save
        expect(subscriber.subscribed).to eq(true)
      end
    end

    context "resubscribe" do
      let(:user) { FactoryGirl.create(:user, subscribed: true) }
      let(:subscription) { double(:subscription) }

      before do
        allow(user).to receive_messages(subscription: subscription)
      end

      context "when update needed" do
        it "calls resubscribe" do
          expect(subscription).to receive(:resubscribe)
          user.save
        end
      end

      context "when update not needed" do
        it "still calls resubscribe, and does nothing" do
          expect(subscription).to receive(:resubscribe)
          expect(subscription).not_to receive(:unsubscribe)
          user.save
        end
      end
    end

    context "subscribing" do
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before { allow(interface).to receive(:subscribe) }

      context "subscribed user" do
        let(:user) { FactoryGirl.create(:user, subscribed: true) }

        it "unsubscribes when calling unsubscribe" do
          expect(interface).to receive(:unsubscribe).with(user.email)
          subscription.unsubscribe
          expect(user.subscribed).to eq(false)
        end

        it "unsubscribes when setting the subscribed column" do
          expect(interface).to receive(:unsubscribe).with(user.email)
          user.subscribed = false
          user.save
          expect(user.subscribed).to eq(false)
        end
      end

      context "non-subscribed user" do
        let(:user) { FactoryGirl.build(:user, subscribed: false) }
        it "does nothing" do
          expect(interface).not_to receive(:unsubscribe)
          subscription.unsubscribe
        end
      end
    end
  end

  context "Mailchimp is disabled" do
    before do
      allow(Spree::Chimpy::Config).to receive_messages(key: nil)

      user = FactoryGirl.create(:user, subscribed: true)
      @subscription = Spree::Chimpy::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.update_member_info }
  end

end

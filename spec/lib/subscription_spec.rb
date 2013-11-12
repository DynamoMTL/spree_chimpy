require 'spec_helper'

describe Spree::Chimpy::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { double(:interface) }

    before do
      Spree::Chimpy::Config.list_name  = 'Members'
      Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email}
      Spree::Chimpy.stub(list: interface)
    end

    context "subscribing users" do
      let(:user)         { FactoryGirl.build(:user, subscribed: true) }
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

      it "subscribes users" do
        interface.should_receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'}, customer: true)
        subscription.subscribe
      end

    end

    context "subscribing subscribers" do
      let(:subscriber)   { Spree::Chimpy::Subscriber.new(email: "test@example.com") }
      let(:subscription) { Spree::Chimpy::Subscription.new(subscriber) }

      it "subscribes subscribers" do
        interface.should_receive(:subscribe).with(subscriber.email, {}, customer: false)
        interface.should_not_receive(:segment)
        subscription.subscribe
      end
    end

    context "resubscribe" do
      let(:user)         { FactoryGirl.create(:user, subscribed: true) }
      let(:subscription) { double(:subscription) }

      before do
        interface.should_receive(:subscribe).once.with(user.email)
        user.stub(subscription: subscription)
      end

      context "when update needed" do
        it "calls resubscribe" do
          subscription.should_receive(:resubscribe)
          user.save
        end
      end

      context "when update not needed" do
        it "still calls resubscribe, and does nothing" do
          subscription.should_receive(:resubscribe)
          subscription.should_not_receive(:unsubscribe)
          user.save
        end
      end
    end

    context "subscribing" do
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before { interface.stub(:subscribe) }

      context "subscribed user" do
        let(:user) { FactoryGirl.create(:user, subscribed: true) }
        it "unsubscribes" do
          interface.should_receive(:unsubscribe).with(user.email)
          subscription.unsubscribe
        end
      end

      context "non-subscribed user" do
        let(:user) { FactoryGirl.build(:user, subscribed: false) }
        it "does nothing" do
          interface.should_not_receive(:unsubscribe)
          subscription.unsubscribe
        end
      end
    end
  end

  context "mail chimp disabled" do
    before do
      Spree::Chimpy::Config.stub(key: nil)

      user = FactoryGirl.build(:user, subscribed: true)
      @subscription = Spree::Chimpy::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.resubscribe {} }
  end

end

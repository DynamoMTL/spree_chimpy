require 'spec_helper'

describe Spree::Hominid::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { mock(:interface) }

    before do
      Spree::Hominid::Config.preferred_list_name  = 'Members'
      Spree::Hominid::Config.preferred_merge_vars = {'EMAIL' => :email}
      Spree::Hominid::Config.stub(list: interface)
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user, subscribed: true) }
      let(:subscriber)   { Spree::Hominid::Subscriber.new(email: "test@example.com") }
      let(:subscriber_with_mergevars) { Spree::Hominid::Subscriber.new(email: "test@example.com", size: '200', height: '30')}
      let(:subscription) { Spree::Hominid::Subscription.new(user) }

      before do
        Spree::Hominid::Config.preferred_merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "subscribes users" do
        interface.should_receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'})

        subscription.subscribe
      end

      it "subscribes subscribers" do
        interface.should_receive(:subscribe).with(subscriber.email, {'SIZE' => nil, 'HEIGHT' => nil})
        subscriber_subscription = Spree::Hominid::Subscription.new(subscriber)
        subscriber_subscription.subscribe
      end

      it "subscribes subscribes with merge vars" do
        interface.should_receive(:subscribe).with(subscriber.email, {'SIZE' => '200', 'HEIGHT' => '30'})
        subscriber_subscription = Spree::Hominid::Subscription.new(subscriber_with_mergevars)
        subscriber_subscription.subscribe
      end
    end

    context "resubscribe" do
      let(:user)         { FactoryGirl.create(:user, subscribed: true) }
      let(:subscription) { mock(:subscription) }

      before do
        interface.should_receive(:subscribe).with(user.email)
        user.stub(subscription: subscription)
      end

      context "when update needed" do
        it "calls resubscribe" do
          subscription.stub(needs_update?: true)
          subscription.should_receive(:resubscribe)
          user.save
        end
      end

      context "when update not needed" do
        it "still calls resubscribe, and does nothing" do
          subscription.stub(needs_update?: false)
          subscription.should_receive(:resubscribe)
          subscription.should_not_receive(:subscribe)
          subscription.should_not_receive(:unsubscribe)
          user.save
        end
      end
    end

    context "subscribing" do
      let(:subscription) { Spree::Hominid::Subscription.new(user) }

      context "subscribed user" do
        let(:user) { FactoryGirl.build(:user, subscribed: true) }
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

    context "needs update?" do
      let(:subscribed)     { FactoryGirl.build(:user, subscribed: true) }
      let(:not_subscribed) { FactoryGirl.build(:user, subscribed: false) }
      let(:subscription)   { Spree::Hominid::Subscription.new(user) }

      before do
        subscribed.email += '.com'
      end

      specify { Spree::Hominid::Subscription.new(subscribed).should         be_needs_update}
      specify { Spree::Hominid::Subscription.new(not_subscribed).should_not be_needs_update}
    end
  end

  context "mail chimp disabled" do
    before do
      Spree::Hominid::Config.stub(list: nil)

      user = FactoryGirl.build(:user, subscribed: true)
      @subscription = Spree::Hominid::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.resubscribe {} }
  end

end

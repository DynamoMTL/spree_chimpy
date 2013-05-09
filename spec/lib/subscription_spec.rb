require 'spec_helper'

describe Spree::Chimpy::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { mock(:interface) }

    before do
      Spree::Chimpy::Config.preferred_list_name  = 'Members'
      Spree::Chimpy::Config.preferred_merge_vars = {'EMAIL' => :email}
      Spree::Chimpy::Config.stub(list: interface)
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user, subscribed: true) }
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before do
        Spree::Chimpy::Config.preferred_merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "subscribes" do
        interface.should_receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'})

        subscription.subscribe
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
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

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
      let(:subscription)   { Spree::Chimpy::Subscription.new(user) }

      before do
        subscribed.email += '.com'
      end

      specify { Spree::Chimpy::Subscription.new(subscribed).needs_update?.should     be_true }
      specify { Spree::Chimpy::Subscription.new(not_subscribed).needs_update?.should be_false }
    end
  end

  context "mail chimp disabled" do
    before do
      Spree::Chimpy::Config.stub(list: nil)

      user = FactoryGirl.build(:user, subscribed: true)
      @subscription = Spree::Chimpy::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.resubscribe {} }
  end

end

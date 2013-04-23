require 'spec_helper'

describe SpreeHominid::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { mock(:interface) }

    before do
      SpreeHominid::Config.preferred_list_name = 'Members'
      SpreeHominid::Config.stub(interface: interface)
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user) }
      let(:subscription) { SpreeHominid::Subscription.new(user) }

      it "subscribes" do
        interface.should_receive(:subscribe).with('Members', user.email)

        subscription.subscribe
      end
    end

    context "sync" do
      let(:user)         { FactoryGirl.create(:user) }
      let(:subscription) { SpreeHominid::Subscription.new(user) }

      before do
        interface.should_receive(:subscribe).with('Members', user.email)
      end

      context "user not modified" do
        it "does nothing" do
          interface.should_not_receive(:unsubscribe)
          subscription.sync
        end
      end

      context "user modified subscribed attributes" do
        context "subscribed to unsubscribed" do
          before { user.update_attributes(subscribed: true)}

          context "unsubscribed to subscribed" do
            before { user.update_attributes(subscribed: false)}
          end
        end
      end

      context "user modified non-tracked attributes"
      context "user modified tracked attribute" do
        context "has changed? method"
        context "doesnt have changed? method"
      end
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user) }
      let(:subscription) { SpreeHominid::Subscription.new(user) }

      it "unsubscribes" do
        interface.should_receive(:unsubscribe).with('Members', user.email)
        subscription.unsubscribe
      end
    end
  end

  context "mail chimp disabled" do
    before do
      SpreeHominid::Config.stub(interface: nil)

      user = FactoryGirl.build(:user)
      @subscription = SpreeHominid::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.sync }
  end

end

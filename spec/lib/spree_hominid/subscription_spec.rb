require 'spec_helper'

describe SpreeHominid::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { mock(:interface) }
    let(:user)         { FactoryGirl.build(:user) }
    let(:subscription) { SpreeHominid::Subscription.new(user) }

    before do
      SpreeHominid::Config.preferred_list_name = 'Members'
      SpreeHominid::Config.stub(interface: interface)
    end

    it "subscribes" do
      interface.should_receive(:subscribe).with('Members', user.email)

      subscription.subscribe
    end

    context "sync" do
    end

    it "unsubscribes" do
      interface.should_receive(:unsubscribe).with('Members', user.email)

      subscription.unsubscribe
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
  end

end

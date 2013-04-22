require 'spec_helper'

describe SpreeHominid::Subscription do
  let(:hominid)      { mock(:hominid) }
 
  context "mail chimp enabled" do
    let(:user)         { FactoryGirl.build(:user) }
    let(:subscription) { SpreeHominid::Subscription.new(user) }

    before do
      SpreeHominid::Config.preferred_key       = 'secret'
      SpreeHominid::Config.preferred_list_name = 'Members'

      Hominid::API.should_receive(:new).with('secret', api_version: '1.3').and_return(hominid)
    end

    it "subscribes" do
      hominid.should_receive(:find_list_by_name).with("Members").and_return('id' => 1234)
      hominid.should_receive(:list_subscribe).with(1234, user.email)

      subscription.subscribe
    end

    context "sync" do
    end

    it "unsubscribes" do
      hominid.should_receive(:find_list_by_name).with("Members").and_return('id' => 1234)
      hominid.should_receive(:list_unsubscribe).with(1234, user.email)

      subscription.unsubscribe
    end
  end

  context "mail chimp disabled" do
    before do
      SpreeHominid::Config.preferred_key = nil
      Hominid::API.should_not_receive(:new)

      user = FactoryGirl.build(:user)
      @subscription = SpreeHominid::Subscription.new(user)

      hominid.should_not_receive(:list_unsubscribe)
      hominid.should_not_receive(:list_subscribe)
    end

    specify { @subscription.subscribe }
  end

end

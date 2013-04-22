require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    let(:user)         { FactoryGirl.create(:user) }
    let(:subscription) { mock(:subscription) }

    before do
      subscription.should_receive(:subscribe)
      SpreeHominid::Subscription.should_receive(:new).with(user).and_return(subscription)
    end

    it "submits after saving" do
      subscription.should_receive(:sync)

      user.save
    end

    it "submits after destroy" do
      subscription.should_receive(:unsubscribe)

      user.destroy
    end
  end
end

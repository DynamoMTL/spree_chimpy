require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    let(:subscription) { mock(:subscription) }

    before do
      subscription.should_receive(:subscribe)
      SpreeHominid::Subscription.should_receive(:new).at_least(1).and_return(subscription)
      @user = FactoryGirl.create(:user)
    end

    it "submits after saving" do
      subscription.should_receive(:sync)

      @user.save
    end

    it "submits after destroy" do
      subscription.should_receive(:unsubscribe)

      @user.destroy
    end
  end
end

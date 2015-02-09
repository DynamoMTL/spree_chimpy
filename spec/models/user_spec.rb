require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      subscription.should_receive(:subscribe)
      Spree::Chimpy::Subscription.should_receive(:new).at_least(1).and_return(subscription)
      @user = create(:user_with_subscribe_option)
    end

    it "submits after saving" do
      subscription.should_receive(:resubscribe)
      @user.save
    end

    it "submits after destroy" do
      subscription.should_receive(:unsubscribe)
      @user.destroy
    end
  end

  context "defaults" do
    it "subscribed by default" do
      Spree::Chimpy::Config.subscribed_by_default = true
      expect(described_class.new.subscribed).to be_truthy
    end

    it "doesnt subscribe by default" do
      Spree::Chimpy::Config.subscribed_by_default = false
      expect(described_class.new.subscribed).to be_falsey
    end
  end
end

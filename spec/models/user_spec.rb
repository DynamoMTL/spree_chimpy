require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      subscription.should_receive(:subscribe)
      Spree::Chimpy::Subscription.should_receive(:new).at_least(1).and_return(subscription)
      @user = FactoryGirl.create(:user)
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
      Spree.user_class.new.subscribed.should == true
    end

    it "doesnt subscribe by default" do
      Spree::Chimpy::Config.subscribed_by_default = false
      Spree.user_class.new.subscribed.should == false
    end
  end
end

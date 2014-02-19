require 'spec_helper'

describe Spree.user_class do
  context "syncing with mail chimp" do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      Spree::Chimpy::Subscription.should_receive(:new).at_least(1).and_return(subscription)
      @user = FactoryGirl.create(:user)
    end

    it "submits after destroy" do
      subscription.should_receive(:unsubscribe)

      @user.destroy
    end
  end

  it "doesnt subscribe by default" do
    Spree.user_class.new.subscribed.should == nil
  end
end

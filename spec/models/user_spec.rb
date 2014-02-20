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


  context "Class Methods" do
    let(:subject) { Spree.user_class }
    before do
      FactoryGirl.create(:user, email: 'bob@sponge.net', subscribed: true)
    end

    it "#customer_has_subscribed?" do
      expect(subject.customer_has_subscribed?('bob@sponge.net')).to be_true
    end
  end

end

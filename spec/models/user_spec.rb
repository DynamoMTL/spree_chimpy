require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    it "submits after creating" do
      SpreeHominid::List.should_receive(:subscribe)
      FactoryGirl.create(:user)
    end

    it "submits after saving" do
      SpreeHominid::List.should_receive(:subscribe).twice
      FactoryGirl.create(:user).save
    end

    it "submits after destroy" do
      SpreeHominid::List.should_receive(:unsubscribe)
      user = FactoryGirl.create(:user)
      user.destroy
    end
  end
end

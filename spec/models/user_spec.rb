require 'spec_helper'

describe Spree::User do
  context "syncing with mail chimp" do
    before do
      SpreeHominid::List.should_receive(:subscribe)
    end

    it "submits after creating" do
      FactoryGirl.create(:user)
    end

    it "submits after saving" do
      SpreeHominid::List.should_receive(:sync)
      FactoryGirl.create(:user).save
    end

    it "submits after destroy" do
      SpreeHominid::List.should_receive(:unsubscribe)
      user = FactoryGirl.create(:user)
      user.destroy
    end
  end
end

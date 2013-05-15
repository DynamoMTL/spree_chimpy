require 'spec_helper'

describe Spree::Chimpy::Subscriber do
  context "without email" do
    it "is invalid" do
      create.should_not be_valid
    end

    it "is not valid without an email" do
      create(email: nil).should have(1).errors_on(:email)
    end

    it "can be valid" do
      create(email: 'test@example.com').should be_valid
    end

    def create(options={})
      Spree::Chimpy::Subscriber.create(options)
    end
  end
end

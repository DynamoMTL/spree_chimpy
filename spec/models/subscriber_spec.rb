require 'spec_helper'

describe Spree::Chimpy::Subscriber do
  context "without email" do
    let(:subscriber) { Spree::Chimpy::Subscriber.new }
    it "is invalid" do
      subscriber.should_not be_valid
    end
    it "is not valid without an email" do
      subscriber.valid?
      subscriber.errors.messages[:email].should include("can't be blank")
    end
  end
end

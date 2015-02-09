require 'spec_helper'

describe Spree::Chimpy::Subscriber do
  context "without email" do
    it "is invalid" do
      expect(create).to_not be_valid
    end

    it "is not valid without an email" do
      record = create(email: nil)
      expect(record.errors[:email].count).to eq 1
    end

    it "can be valid" do
      expect(create(email: 'test@example.com')).to be_valid
    end

    def create(options={})
      Spree::Chimpy::Subscriber.create(options)
    end
  end
end

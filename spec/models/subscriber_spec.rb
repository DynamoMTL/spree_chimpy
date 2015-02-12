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

    it 'is not valid without an email' do
      expect(described_class.new(email: nil)).to have(1).errors_on(:email)
    end

    it 'can be valid' do
      expect(described_class.new(email: 'test@example.com')).to be_valid
    end
  end
end

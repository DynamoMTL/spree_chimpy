require 'spec_helper'

describe Spree::Chimpy::Subscriber do
  context "without email" do
    it 'is not valid without an email' do
      record = described_class.new(email: nil)
      record.valid?
      expect(record.errors[:email].size).to eq(1)
    end

    it 'can be valid' do
      expect(described_class.new(email: 'test@example.com')).to be_valid
    end
  end

  context 'with wrong email' do
    it 'is invalid when bad domain' do
      expect(described_class.new(email: 'test@example')).to_not be_valid
    end

    it 'is invalid when missing @domain' do
      expect(described_class.new(email: 'test')).to_not be_valid
    end
  end
end

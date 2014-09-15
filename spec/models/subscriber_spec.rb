require 'spec_helper'

describe Spree::Chimpy::Subscriber do

  context 'without email' do
    it 'is invalid' do
      expect(described_class.create).not_to be_valid
    end

    it 'is not valid without an email' do
      expect(described_class.new(email: nil)).to have(1).errors_on(:email)
    end

    it 'can be valid' do
      expect(described_class.new(email: 'test@example.com')).to be_valid
    end
  end
end

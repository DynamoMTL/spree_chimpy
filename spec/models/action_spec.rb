require 'spec_helper'

describe Spree::Chimpy::Action do
  context "Validation" do
    it "can be valid" do
      expect(Spree::Chimpy::Action.create(email: 'test@example.com')).to be_valid
    end

    it "is invalid without email" do
      expect(Spree::Chimpy::Action.new(email: nil)).not_to be_valid
    end

    it "is invalid with bad emails" do
      bad_emails = %w(23stnoesthn @@@stnhoeu.com tnhe@stnhs 0932e@.nte).map do |email|
        Spree::Chimpy::Action.new(email: email, action: :subscribe)
      end
     
      bad_emails.each {|email| expect(email).to be_invalid }
    end

  end


end

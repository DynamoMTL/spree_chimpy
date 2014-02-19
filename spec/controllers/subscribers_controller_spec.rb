require 'spec_helper'

describe Spree::Chimpy::SubscribersController, type: :controller do
  context "subscribe" do
    it "should registration customer" do
      spree_post :subscribe, {signupEmail: 'tester@woolandthegang.com', source: 'Website - Hero'}
      
      should_be_successful(response)
      expect(Spree::Chimpy::Action.count).to    eq(1)
      expect(Spree::Chimpy::Action.first.source).to    eq('Website - Hero')
      expect(Spree.user_class.first.subscribed).to    be_true
    end
    
    it "should return error message" do
      spree_post :subscribe, {signupEmail: 'test'}

      should_be_failure(response)
      expect(Spree::Chimpy::Action.count).to    eq(0)
      expect(Spree.user_class.first.subscribed).to    be_false
      
    end
    
    it "should only accept one email per action" do
      2.times do
        spree_post :subscribe, {signupEmail: 'tester@woolandthegang.com'}
      end
      should_be_failure(response)
    end
  end

  
  context "unsubscribe" do
    before do 
      create(:user, email: 'luther@bbc.co.uk', subscribed: true)
      Spree::Chimpy::Action.create(email: 'luther@bbc.co.uk', action: :subscribe)
    end
   
    it "should remove customer from newsletter" do
      spree_post :unsubscribe, {signupEmail: 'luther@bbc.co.uk'}
      should_be_successful(response)
    end

  end

  def should_be_successful(response)
    expect(response).to be_success
    response_hash = JSON.parse(response.body)
    response_hash['response'].should eql('success')
  end

  def should_be_failure(response)
    expect(response).to be_success
    response_hash = JSON.parse(response.body)
    response_hash['response'].should eql('failure')
  end

end

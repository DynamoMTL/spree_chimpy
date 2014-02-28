require 'spec_helper'

describe Spree::Chimpy::SubscribersController, type: :controller do
  before do
    Spree::Chimpy::Config.key = nil
  end
  context "subscribe" do
    before do
      user = create(:user, email: 'luther@bbc.co.uk', subscribed: false)
      subject.stub(:find_or_create_user).and_return(user)
    end

    it "should register the customer" do
      spree_post :subscribe, {signupEmail: 'luther@bbc.co.uk', source: 'Website - Hero'}
      
      should_be_successful(response)
      expect(Spree::Chimpy::Action.count).to    eq(1)
      expect(Spree::Chimpy::Action.first.source).to    eq('Website - Hero')
      expect(Spree.user_class.find_by(email:'luther@bbc.co.uk').subscribed).to    be_true
    end
    
    it "should return error message for invalid email" do
      user = build(:user, email: 'luther', subscribed: false)
      subject.stub(:find_or_create_user).and_return(user)
      spree_post :subscribe, {signupEmail: 'luther'}

      should_be_failure(response)
      expect(Spree::Chimpy::Action.count).to    eq(0)
      expect(Spree.user_class.find_by(email:'luther@bbc.co.uk').subscribed).to    be_false
    end
    
    it "should only accept one email per action" do
      2.times do
        spree_post :subscribe, {signupEmail: 'luther@bbc.co.uk'}
      end
      should_be_failure(response)
    end
  end

  
  context "unsubscribe" do
    before do 
      user = create(:user, email: 'luther@bbc.co.uk', subscribed: true)
      Spree::Chimpy::Action.create(email: 'luther@bbc.co.uk', action: :subscribe)
      subject.stub(:find_or_create_user).and_return(user)
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

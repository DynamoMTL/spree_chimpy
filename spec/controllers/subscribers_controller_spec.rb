require 'spec_helper'

describe Spree::Chimpy::SubscribersController, type: :controller do
  before do
    Spree::Chimpy::Config.key = nil
  end
  context "subscribe" do
    before do
      user = create(:user, email: 'luther@bbc.co.uk', subscribed: false)
      allow(subject).to receive(:find_or_create_user).and_return(user)
    end

    it "should register the customer" do
      spree_post :subscribe, {signupEmail: 'luther@bbc.co.uk', source: 'Website - Hero'}

      should_be_successful(response)
      expect(Spree::Chimpy::Action.count).to    eq(1)
      expect(Spree::Chimpy::Action.first.source).to    eq('Website - Hero')
      expect(Spree.user_class.find_by(email:'luther@bbc.co.uk').subscribed).to be true
    end

    it "should return error message for invalid email" do
      user = build(:user, email: 'luther', subscribed: false)
      allow(subject).to receive(:find_or_create_user).and_return(user)
      spree_post :subscribe, {signupEmail: 'luther'}

      should_be_failure(response)
      expect(Spree::Chimpy::Action.count).to    eq(0)
      expect(Spree.user_class.find_by(email:'luther@bbc.co.uk').subscribed).to be false
    end
  end

  context "subscribe to list of choice" do
    let(:interface) { double('List') }
    before do
      expect(Spree::Chimpy::Interface::List).to receive(:new).with('Testing', anything, anything).and_return(interface)
      expect(interface).to receive(:direct_subscribe).with('luther@bbc.co.uk', {"SOURCE" => 'Test Source'})
    end

    it "should subsribe directly" do
      spree_post :subscribe_to_list, {signupEmail: 'luther@bbc.co.uk', list_name: 'Testing', source: 'Test Source'}
      should_be_successful(response)
    end

  end


  context "unsubscribe" do
    before do
      user = create(:user, email: 'luther@bbc.co.uk', subscribed: true)
      Spree::Chimpy::Action.create(email: 'luther@bbc.co.uk', action: :subscribe)
      allow(subject).to receive(:find_or_create_user).and_return(user)
    end

    it "should remove customer from newsletter" do
      spree_post :unsubscribe, {signupEmail: 'luther@bbc.co.uk'}
      should_be_successful(response)
    end

  end

  def should_be_successful(response)
    expect(response).to be_success
    response_hash = JSON.parse(response.body)
    expect(response_hash['response']).to eql('success')
  end

  def should_be_failure(response)
    expect(response).to be_success
    response_hash = JSON.parse(response.body)
    expect(response_hash['response']).to eql('failure')
  end

end

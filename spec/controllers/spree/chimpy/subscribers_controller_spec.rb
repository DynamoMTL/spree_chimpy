require 'spec_helper'

describe Spree::Chimpy::SubscribersController do

  let(:spree_chimpy_subscriber) { create(:subscriber) }
  let(:valid_attributes) { attributes_for(:subscriber) }

  context '#create' do
    it 'raise error when empty hash found' do
      expect { spree_post :create, chimpy_subscriber: {} }.to raise_error
    end
  end
end
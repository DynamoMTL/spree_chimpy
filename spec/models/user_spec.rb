require 'spec_helper'

describe Spree::User do
  context 'syncing with mail chimp' do
    let(:subscription) { double(:subscription, needs_update?: true) }

    before do
      allow(subscription).to receive(:subscribe)
      allow(Spree::Chimpy::Subscription).to receive(:new) { subscription }
      @user = create(:user_with_subscribe_option)
    end

    it 'submits after destroy' do
      allow(subscription).to receive(:unsubscribe)
      @user.destroy
    end
  end

  context 'defaults' do
    it 'subscribed by default' do
      Spree::Chimpy::Config.subscribed_by_default = true
      expect(described_class.new.subscribed).to be_truthy
    end

    it 'doesnt subscribe by default' do
      Spree::Chimpy::Config.subscribed_by_default = false
      expect(described_class.new.subscribed).to be_falsey
    end
  end
end

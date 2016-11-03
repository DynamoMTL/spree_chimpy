require 'spec_helper'

describe Spree::Order do
  let(:key) { '857e2096b21e5eb385b9dce2add84434-us14' }
  let(:order) { create(:completed_order_with_totals) }

  it 'has a source' do
    order = Spree::Order.new
    expect(order).to respond_to(:source)
  end

  context 'notifying mail chimp' do
    before do
      Spree::Chimpy::Config.key = nil

      @not_completed_order = create(:order)

      Spree::Chimpy::Config.key = key
    end

    subject { Spree::Chimpy }

    it 'doesnt update when order is not completed' do
      expect(subject).to_not receive(:enqueue)
      @not_completed_order.update!
    end

    it 'updates when order is completed' do
      new_order = create(:completed_order_with_pending_payment, state: 'confirm')
      expect(subject).to receive(:enqueue).with(:order, new_order)
      new_order.next
    end

    it 'sync when order is completed' do
      expect(subject).to receive(:enqueue).with(:order, order)
      order.cancel!
    end
  end
end

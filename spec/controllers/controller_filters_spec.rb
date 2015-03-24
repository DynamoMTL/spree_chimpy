require 'spec_helper'

describe ::Spree::StoreController do
  controller(::Spree::StoreController) do
    def index
      head :ok
    end
  end

  let(:user) { create(:user) }
  subject { controller }

  before do
    allow(subject).to receive(:try_spree_current_user).and_return(user)
    subject.session[:order_id] = 'R1919'
  end

  it 'sets the attributes for order if eid/cid is set in session' do
    subject.session[:mc_eid] = '1234'
    subject.session[:mc_cid] = 'abcd'
    expect(subject).to receive(:find_mail_chimp_params)

    get :index
  end

  it 'sets the attributes for the order if eid/cid is set in the params' do
    expect(subject).to receive(:find_mail_chimp_params)

    get :index, mc_eid: '1234', mc_cid: 'abcd'
  end

  it 'does not call find mail chimp params method if no eid/cid' do
    expect(subject).to_not receive(:find_mail_chimp_params)

    get :index
  end
end

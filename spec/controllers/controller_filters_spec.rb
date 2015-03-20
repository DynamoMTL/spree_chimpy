require 'spec_helper'

describe ::Spree::StoreController do

  before do
    subject.session[:mc_eid] = '1234'
    subject.session[:mc_cid] = 'abcd'
  end

  it 'sets the source attributes on order' do
    binding.pry
    get :index
    expect(subject).to receive(:find_mail_chimp_params)
  end

end

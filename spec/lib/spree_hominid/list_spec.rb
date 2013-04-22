require 'spec_helper'

describe SpreeHominid::List do
  let(:user)    { FactoryGirl.build(:user) }
  let(:hominid) { mock(:hominid) }

  before do
    SpreeHominid::Config.preferred_key       = 'secret'
    SpreeHominid::Config.preferred_list_name = 'Members'

    Hominid::API.should_receive(:new).with('secret').at_least(1).and_return(hominid)
  end

  it "subscribes" do
    hominid.should_receive(:find_by_name).with("Members").and_return('id' => 1234)
    hominid.should_receive(:list_subscribe).with(1234, user.email)

    SpreeHominid::List.subscribe(user)
  end

  context "sync"
  context "unsubscribe"
end

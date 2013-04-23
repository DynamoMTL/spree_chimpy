require 'spec_helper'

describe SpreeHominid::Interface do
  let(:interface) { SpreeHominid::Interface.new('1234') }
  let(:api)       { mock(:api) }

  before do
    Hominid::API.should_receive(:new).with('1234', api_version: '1.3').and_return(api)
  end

  it "subscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_subscribe).with('a3d3', 'user@example.com', update_existing: true)
    interface.subscribe('Members', "user@example.com")
  end

  it "unsubscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_unsubscribe).with('a3d3', 'user@example.com')
    interface.unsubscribe('Members', "user@example.com")
  end

  it "find list id" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    interface.find_list_id('Members')
  end

  it "checks if merge var exists" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_merge_vars).with('a3d3').and_return([{'tag' => 'FOO'}, {'tag' => 'BAR'}])
    interface.merge_vars('Members').should == %w(FOO BAR)
  end

  # add_merge_var
  # find_merge_var
end

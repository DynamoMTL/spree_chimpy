require 'spec_helper'

describe Spree::Chimpy::Interface::List do
  let(:interface) { Spree::Chimpy::Interface::List.new('1234', 'Members', 'customers') }
  let(:api)       { mock(:api) }

  before do
    Spree::Chimpy::Config.preferred_key = '1234'
    Hominid::API.should_receive(:new).with('1234', api_version: '1.3').and_return(api)
  end

  it "subscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_subscribe).with('a3d3', 'user@example.com', {'SIZE' => '10'}, 'html', true, true)
    interface.subscribe("user@example.com", 'SIZE' => '10')
  end

  it "unsubscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_unsubscribe).with('a3d3', 'user@example.com')
    interface.unsubscribe("user@example.com")
  end

  it "find list id" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    interface.list_id
  end

  it "checks if merge var exists" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_merge_vars).with('a3d3').and_return([{'tag' => 'FOO'}, {'tag' => 'BAR'}])
    interface.merge_vars.should == %w(FOO BAR)
  end

  it "adds a merge var" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_merge_var_add).with('a3d3', 'SIZE', 'Your Size')
    interface.add_merge_var('SIZE', 'Your Size')
  end
end

require 'spec_helper'

describe Spree::Chimpy::Interface::List do
  let(:interface) { Spree::Chimpy::Interface::List.new('Members', 'customers', true) }
  let(:api)       { double(:api) }

  before do
    Spree::Chimpy::Config.key = '1234'
    Mailchimp::API.should_receive(:new).with('1234', { timeout: 60 }).and_return(api)
    api.should_receive(:lists).and_return({"data" => [{"name" => "Members", "id" => "a3d3" }]})
  end

  it "subscribes" do
    api.should_receive(:list_subscribe).with({:id => 'a3d3', :email_address => 'user@example.com', :merge_vars => {'SIZE' => '10'}, :email_type => 'html', :double_optin => true, :update_existing => true})
    interface.subscribe("user@example.com", 'SIZE' => '10')
  end

  it "unsubscribes" do
    api.should_receive(:list_unsubscribe).with({:id => 'a3d3', :email_address => 'user@example.com'})
    interface.unsubscribe("user@example.com")
  end

  it "segments users" do
    api.should_receive(:list_subscribe).with(id: 'a3d3', email_address: 'user@example.com', merge_vars: {'SIZE' => '10'}, email_type: 'html', update_existing: true, double_optin: true)
    api.should_receive(:list_static_segments).with(id: 'a3d3').and_return([{"id" => '123', "name" => "customers"}])
    api.should_receive(:list_static_segment_members_add).with(id: 'a3d3', seg_id: '123', batch: ["user@example.com"])
    interface.subscribe("user@example.com", {'SIZE' => '10'}, {customer: true})
  end

  it "segments" do
    api.should_receive(:list_static_segments).with(id: 'a3d3').and_return([{"id" => '123', "name" => "customers"}])
    api.should_receive(:list_static_segment_members_add).with(id: 'a3d3', seg_id: '123', batch: ["test@test.nl", "test@test.com"])
    interface.segment(["test@test.nl", "test@test.com"])
  end

  it "find list id" do
    interface.list_id
  end

  it "checks if merge var exists" do
    api.should_receive(:list_merge_vars).with({:id => 'a3d3'}).and_return([{'tag' => 'FOO'}, {'tag' => 'BAR'}])
    interface.merge_vars.should == %w(FOO BAR)
  end

  it "adds a merge var" do
    api.should_receive(:list_merge_var_add).with({:id => "a3d3", :tag => "SIZE", :name => "Your Size"})
    interface.add_merge_var('SIZE', 'Your Size')
  end
end

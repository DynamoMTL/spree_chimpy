require 'spec_helper'

describe Spree::Chimpy::Interface::List do
  let(:interface) { Spree::Chimpy::Interface::List.new('Members', 'customers', true) }
  let(:api)       { double('api', lists: double) }
  let(:merge_vars) { {'SIZE' => '10'} }
  let(:list_id) { 'a3d3' }
  let(:double_optin) { true }
  let(:update_existing) { true }
  let(:segment_id) { 123 }

  before(:each) do
    Spree::Chimpy.stub(:api).and_return(api)
    api.lists.should_receive(:list).with({'list_name' => 'Members'}).and_return({"data" => [{"name" => "Members", "id" => list_id }]})
  end

  it "subscribes" do
    api.lists.should_receive(:member_info).with(list_id, [{email:'user@example.com'}]).and_return(nil)
    api.lists.should_receive(:subscribe).with(list_id, {email:'user@example.com'}, merge_vars, 'html', double_optin, update_existing)
    interface.subscribe("user@example.com", 'SIZE' => '10')
  end

  it "does not subscribe when the user has unsubscribed from remote" do
    user = FactoryGirl.create(:user, email: "user@example.com", subscribed: true)
    api.lists.should_receive(:member_info).with(list_id, [{email:'user@example.com'}]).and_return({'success_count'=>1, 'data' => ['status'=>'unsubscribed']})
    api.lists.should_not_receive(:subscribe)
    
    interface.subscribe("user@example.com", 'SIZE' => '10')
    expect(user.reload.subscribed).to be_false
  end

  it "unsubscribes" do
    api.lists.should_receive(:unsubscribe).with(list_id, {email: 'user@example.com'})
    interface.unsubscribe("user@example.com")
  end

  it "segments users" do
    api.lists.should_receive(:member_info).with(list_id, [{email:'user@example.com'}]).and_return(nil)
    api.lists.should_receive(:subscribe).with(list_id, {email:'user@example.com'}, merge_vars, 'html', double_optin, update_existing)
    api.lists.should_receive(:segments).with(list_id, 'static').and_return({'static' => [{"id" => segment_id, "name" => "customers"}] })
    api.lists.should_receive(:static_segment_members_add).with(list_id, segment_id, [{email: "user@example.com"}])
    interface.subscribe("user@example.com", {'SIZE' => '10'}, {customer: true})
  end

  it "segments" do
    api.lists.should_receive(:segments).with(list_id, 'static').and_return({'static' => [{"id" => segment_id, "name" => "customers"}] })
    api.lists.should_receive(:static_segment_members_add).with(list_id, segment_id, [{email: "test@test.nl"}, {email: "test@test.com"}])
    interface.segment(["test@test.nl", "test@test.com"])
  end

  it "finds list id" do
    interface.list_id
  end

  it "checks if merge var exists" do
    api.lists.should_receive(:merge_vars).with([list_id]).and_return({'data' => [{'merge_vars' => [{'tag' => 'FOO'}, {'tag' => 'BAR'}] }] })
    interface.merge_vars.should == %w(FOO BAR)
  end

  it "adds a merge var" do
    api.lists.should_receive(:merge_var_add).with(list_id, "SIZE", "Your Size")
    interface.add_merge_var('SIZE', 'Your Size')
  end

  it "directly subscribes" do
    api.lists.should_receive(:subscribe).with(list_id, {email:'user@example.com'}, {}, 'html', double_optin, update_existing)
    interface.direct_subscribe("user@example.com")
  end

end

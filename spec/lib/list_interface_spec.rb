require 'spec_helper'

describe Spree::Chimpy::Interface::List do
  let(:interface) { described_class.new('Members', 'customers', true, true, nil) }
  let(:api)       { double(:api) }
  let(:lists)     { double(:lists, :[] => [{"name" => "Members", "id" => "a3d3" }] ) }
  let(:key)       { 'e025fd58df5b66ebd5a709d3fcf6e600-us8' }

  before do
    Spree::Chimpy::Config.key = key
    Mailchimp::API.should_receive(:new).with(key, { timeout: 60 }).and_return(api)
    lists.stub(:list).and_return(lists)
    api.stub(:lists).and_return(lists)
  end

  context "#subscribe" do
    it "subscribes" do
      expect(lists).to receive(:subscribe).
        with('a3d3', {email: 'user@example.com'},
              {'SIZE' => '10'}, 'html', true, true, true, true)
      interface.subscribe("user@example.com", 'SIZE' => '10')
    end

    it "ignores exception Mailchimp::ListInvalidImportError" do
      expect(lists).to receive(:subscribe).
        with('a3d3', {email: 'user@example.com'},
              {}, 'html', true, true, true, true).and_raise Mailchimp::ListInvalidImportError
      expect(lambda { interface.subscribe("user@example.com") }).not_to raise_error
    end
  end

  context "#unsubscribe" do
    it "unsubscribes" do
      expect(lists).to receive(:unsubscribe).with('a3d3', { email: 'user@example.com' })
      interface.unsubscribe("user@example.com")
    end

    it "ignores exception Mailchimp::EmailNotExistsError" do
      expect(lists).to receive(:unsubscribe).with('a3d3', { email: 'user@example.com' }).and_raise Mailchimp::EmailNotExistsError
      expect(lambda { interface.unsubscribe("user@example.com") }).not_to raise_error
    end

    it "ignores exception Mailchimp::ListNotSubscribedError" do
      expect(lists).to receive(:unsubscribe).with('a3d3', { email: 'user@example.com' }).and_raise Mailchimp::ListNotSubscribedError
      expect(lambda { interface.unsubscribe("user@example.com") }).not_to raise_error
    end
  end

  context "member info" do
    it "find when no errors" do
      expect(lists).to receive(:member_info).with('a3d3', [{:email=>"user@example.com"}]).and_return({'success_count' => 1, 'data' => [{'response' => 'foo'}]})
      expect(interface.info("user@example.com")).to eq({:response => 'foo'})
    end

    it "returns empty hash on error" do
      expect(lists).to receive(:member_info).with('a3d3', [{:email=>'user@example.com'}]).and_return({'data' => [{'error' => 'foo'}]})
      expect(interface.info("user@example.com")).to eq({})
    end
  end

  it "segments users" do
    expect(lists).to receive(:subscribe).
      with('a3d3', {email: 'user@example.com'}, {'SIZE' => '10'},
            'html', true, true, true, true)
    expect(lists).to receive(:static_segments).with('a3d3').and_return([{"id" => 123, "name" => "customers"}])
    expect(lists).to receive(:static_segment_members_add).with('a3d3', 123, [{:email => "user@example.com"}])
    interface.subscribe("user@example.com", {'SIZE' => '10'}, {customer: true})
  end

  it "segments" do
    expect(lists).to receive(:static_segments).with('a3d3').and_return([{"id" => '123', "name" => "customers"}])
    expect(lists).to receive(:static_segment_members_add).with('a3d3', 123, [{email: "test@test.nl"}, {email: "test@test.com"}])
    interface.segment(["test@test.nl", "test@test.com"])
  end

  it "find list id" do
    interface.list_id
  end

  it "checks if merge var exists" do
    expect(lists).to receive(:merge_vars).with(['a3d3']).and_return( {'success_count' => 1,
                                                                     'data' => [{'id' => 'a3d3',
                                                                                'merge_vars' => [{'tag' => 'FOO'},
                                                                                                 {'tag' => 'BAR'}] }]} )
    expect(interface.merge_vars).to match_array %w(FOO BAR)
  end

  it "adds a merge var" do
    expect(lists).to receive(:merge_var_add).with("a3d3", "SIZE", "Your Size")
    interface.add_merge_var('SIZE', 'Your Size')
  end
end

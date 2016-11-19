require 'spec_helper'

describe Spree::Chimpy::Interface::List do
  let(:interface)         { described_class.new('Members', 'customers', true, true, nil) }
  let(:api)               { double(:api) }
  let(:list_id)           { "a3d3" }
  let(:segment_id)        { 3887 }
  let(:mc_eid)            { "ef3176d4dd" }
  #let(:lists)             { double(:lists, [{"name" => "Members", "id" => list_id }] ) }
  let(:key)               { '857e2096b21e5eb385b9dce2add84434-us14' }

  let(:lists_response)    { {"lists"=>[{"id"=>list_id, "name"=>"Members"}]} }
  let(:segments_response) { {"segments"=>[{"id"=>segment_id, "name"=>"Customers"}]} }
  let(:info_response)     { {"email_address"=>email, "merge_fields"=>{"FNAME"=>"Jane", "LNAME"=>"Doe","SIZE" => '10'}} }
  let(:merge_response)    { {"merge_fields"=>[{"tag"=>"FNAME", "name"=>"First Name"}, {"tag"=>"LNAME", "name"=>"Last Name"}]} }
  let(:members_response)  { {"members"=> [{"id" => "customer_123", "email_address"=>email, "unique_email_id"=>mc_eid, "email_type"=>"html", "status"=>"subscribed", "merge_fields"=>{"FNAME"=>"", "LNAME"=>"", "SIZE"=>"10"}}] } }

  let(:email)             { 'user@example.com' }

  let(:members_api)       { double(:members_api) }
  let(:member_api)        { double(:member_api) }
  let(:lists_api)         { double(:lists_api) }
  let(:list_api)          { double(:list_api) }
  let(:segments_api)      { double(:segments_api) }
  let(:segment_api)       { double(:segment_api) }
  let(:merges_api)        { double(:merges_api) }

  before do
    Spree::Chimpy::Config.key = key
    Gibbon::Request.stub(:new).with({ api_key: key, timeout: 60 }).and_return(api)

    api.stub(:lists).and_return(lists_api)
    lists_api.stub(:retrieve).and_return(lists_response)

    api.stub(:lists).with(list_id).and_return(list_api)

    list_api.stub(:members).and_return(members_api)
    list_api.stub(:members).with(Digest::MD5.hexdigest(email)).and_return(member_api)

    list_api.stub(:segments).and_return(segments_api)
    list_api.stub(:segments).with(segment_id).and_return(segment_api)

    list_api.stub(:merge_fields).and_return(merges_api)
  end

  context "#subscribe" do
    it "subscribes" do
      expect(member_api).to receive(:upsert)
        .with(hash_including(body: {email_address: email, status: "subscribed", merge_fields: { 'SIZE' => '10' }, email_type: 'html' }))
      interface.subscribe(email, 'SIZE' => '10')
    end

    it "ignores exception Gibbon::MailChimpError" do
      expect(member_api).to receive(:upsert)
        .and_raise Gibbon::MailChimpError
      expect(lambda { interface.subscribe(email) }).not_to raise_error
    end
  end

  context "#unsubscribe" do
    it "unsubscribes" do
      expect(member_api).to receive(:update).with(
        hash_including(body: { email_address: email, status: "unsubscribed" })
      )
      interface.unsubscribe(email)
    end

    it "ignores exception Gibbon::MailChimpError" do
      expect(member_api).to receive(:update).and_raise Gibbon::MailChimpError
      expect(lambda { interface.unsubscribe(email) }).not_to raise_error
    end
  end

  context "member info" do
    it "find when no errors" do
      expect(member_api).to receive(:retrieve).with(
        { params: { "fields" => "email_address,merge_fields,status" } }
      ).and_return(info_response)
      expect(interface.info(email)).to include(
        email_address: email,
        merge_fields: { "FNAME" => "Jane", "LNAME" => "Doe", "SIZE" => '10'}
      )
    end
    it "adds legacy field email for backwards compatibility" do
      expect(member_api).to receive(:retrieve).with(
        { params: { "fields" => "email_address,merge_fields,status" } }
      ).and_return(info_response)
      expect(interface.info(email)).to include(email: email)
    end

    it "returns empty hash on error" do
      expect(member_api).to receive(:retrieve).and_raise Gibbon::MailChimpError
      expect(interface.info("user@example.com")).to eq({})
    end

    describe "email_for_id" do
      it "can find the email address for a unique_email_id (mc_eid)" do
        expect(members_api).to receive(:retrieve).with(
          params: { "unique_email_id" => mc_eid, "fields" => "members.id,members.email_address" }
        ).and_return(members_response)
        expect(interface.email_for_id(mc_eid)).to eq email
      end
      it "returns nil when empty array returned" do
        expect(members_api).to receive(:retrieve).with(
          params: { "unique_email_id" => mc_eid, "fields" => "members.id,members.email_address" }
        ).and_return({ "members" => [] })
        expect(interface.email_for_id(mc_eid)).to be_nil
      end
      it "returns nil on error" do
        expect(members_api).to receive(:retrieve).and_raise Gibbon::MailChimpError
        expect(interface.email_for_id(mc_eid)).to be_nil
      end
    end
  end

  it "segments users" do
    expect(member_api).to receive(:upsert)
      .with(hash_including(
        body: {
          email_address: email,
          status: "subscribed",
          merge_fields: { 'SIZE' => '10' },
          email_type: 'html'
        })
      )

    expect(segments_api).to receive(:retrieve).with(
      params: { "fields" => "segments.id,segments.name"}
    ).and_return(segments_response)

    expect(segment_api).to receive(:create).with(
      body: { members_to_add: [email] }
    )
    interface.subscribe("user@example.com", {'SIZE' => '10'}, {customer: true})
  end

  it "segments" do
    emails = ["test@test.nl", "test@test.com"]
    expect(segments_api).to receive(:retrieve).with(
      params: { "fields" => "segments.id,segments.name"}
    ).and_return(segments_response)

    expect(segment_api).to receive(:create).with(
      body: { members_to_add: emails }
    )
    interface.segment(emails)
  end

  it "creates the segment" do
    expect(segments_api).to receive(:create).with(
      body: {
        name: "customers",
        static_segment: []
      }
    ).and_return({ "id" => 3959 })
    expect(interface.create_segment).to eq 3959
  end

  it "find list id" do
    expect(interface.list_id).to eq list_id
  end

  it "checks if merge var exists" do
    expect(merges_api).to receive(:retrieve)
      .with(params: { "fields" => "merge_fields.tag,merge_fields.name" }).and_return(merge_response)
    expect(interface.merge_vars).to match_array %w(FNAME LNAME)
  end

  it "adds a merge var" do
    expect(merges_api).to receive(:create).with(body: {
      tag: "SIZE", name: "Your Size", type: "text"
    })
    interface.add_merge_var('SIZE', 'Your Size')
  end

  it "does not segment users when no segment provided" do
    Spree::Chimpy::Config.customer_segment_name = ""
    allow(lists).to receive(:subscribe)

    expect(lists).to_not receive(:static_segment_members_add)

    interface.subscribe("user@example.com", {'SIZE' => '10'}, {customer: true})
  end
end

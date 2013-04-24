require 'spec_helper'

describe SpreeHominid::Configuration do

  context "enabled" do
    before  { SpreeHominid::Interface.should_receive(:new).any_number_of_times.with('1234', 'Members').and_return(:interface) }
    subject { config(key: '1234', list_name: 'Members') }

    specify         { should be_enabled }
    its(:interface) { should == :interface }
  end

  context "disabled" do
    subject { config(key: nil) }

    specify         { should_not be_enabled }
    its(:interface) { should be_nil }
  end

  def config(options = {})
    config = SpreeHominid::Configuration.new
    config.preferred_key       = options[:key]
    config.preferred_list_name = options[:list_name]
    config
  end
end

require 'spec_helper'

describe Spree::Chimpy do

  context "enabled" do
    before do
      allow(Spree::Chimpy::Interface::List).to receive(:new).and_return(:list)
      allow(Spree::Chimpy::Interface::Orders).to receive(:new).and_return(:orders)
      config(key: '1234', list_name: 'Members')
    end

    specify      { is_expected.to be_configured }
    its(:list)   { should == :list }
    its(:orders) { should == :orders }
  end

  context "disabled" do
    before { config(key: nil) }

    specify      { is_expected.not_to be_configured }
    its(:list)   { should be_nil }
    its(:orders) { should be_nil }
  end

  context "sync merge vars" do
    before do
      allow(subject).to receive(:list).and_return(double('List'))
      config(key: '1234',
             list_name: 'Members',
             merge_vars: {'EMAIL' => :email, 'FNAME' => :first_name, 'LNAME' => :last_name})
    end

    it "adds var for each" do
      expect(subject.list).to receive(:merge_vars).and_return([])
      expect(subject.list).to receive(:add_merge_var).with('FNAME', 'First Name')
      expect(subject.list).to receive(:add_merge_var).with('LNAME', 'Last Name')

      Spree::Chimpy.sync_merge_vars
    end

    it "skips vars that exist" do
      expect(subject.list).to receive(:merge_vars).and_return(%w(EMAIL FNAME))
      expect(subject.list).to receive(:add_merge_var).with('LNAME', 'Last Name')

      Spree::Chimpy.sync_merge_vars
    end

    it "doesnt sync if all exist" do
      expect(subject.list).to receive(:merge_vars).and_return(%w(EMAIL FNAME LNAME))
      expect(subject.list).not_to receive(:add_merge_var)

      Spree::Chimpy.sync_merge_vars
    end
  end

  def config(options = {})
    config = Spree::Chimpy::Configuration.new
    config.key        = options[:key]
    config.list_name  = options[:list_name]
    config.merge_vars = options[:merge_vars]
    config
  end
end

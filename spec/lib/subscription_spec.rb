require 'spec_helper'

describe Spree::Chimpy::Subscription do

  context "Mailchimp enabled" do
    let(:interface)    { double(:interface) }

    before do
      Spree::Chimpy::Config.list_name  = 'Members'
      Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email}
      Spree::Chimpy.stub(list: interface)
      # Delayed::Worker.delay_jobs = false # enable if test_failures
      Spree::Chimpy::Config.stub(key: '1234')
    end

    context "subscribes users" do
      let(:user)         { FactoryGirl.create(:user, subscribed: false) }
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before do
        Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "successfully" do
        interface.should_receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'}, customer: true)
        subscription.subscribe
      end

    end

    context "who are not enrolled" do
      let(:subscriber)   { FactoryGirl.create(:user, enrolled: false) }
      let(:subscription) { Spree::Chimpy::Subscription.new(subscriber) }

      it "subscribes subscribers" do
        interface.should_receive(:subscribe).with(subscriber.email, {}, customer: false)
        interface.should_not_receive(:segment)
        subscription.subscribe

        subscriber.subscribed.should == true
      end
    end

    context "subscribing" do
      let(:subscription) { Spree::Chimpy::Subscription.new(user) }

      before { interface.stub(:subscribe) }

      context "subscribed user" do
        let(:user) { FactoryGirl.create(:user, subscribed: true) }

        it "unsubscribes" do
          interface.should_receive(:unsubscribe).with(user.email)
          subscription.unsubscribe
          user.subscribed.should == false
        end
      end

      context "non-subscribed user" do
        let(:user) { FactoryGirl.build(:user, subscribed: false) }
        it "does nothing" do
          interface.should_not_receive(:unsubscribe)
          subscription.unsubscribe
        end
      end
    end
  end

  context "Mailchimp is disabled" do
    before do
      Spree::Chimpy::Config.stub(key: nil)

      user = FactoryGirl.create(:user, subscribed: true)
      @subscription = Spree::Chimpy::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.update_member_info }
  end

end

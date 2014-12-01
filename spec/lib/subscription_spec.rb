require 'spec_helper'

describe Spree::Chimpy::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { double(:interface) }

    before do
      Spree::Chimpy::Config.list_name  = 'Members'
      Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email}
      Spree::Chimpy.stub(list: interface)
    end

    context "subscribing users" do
      let(:user)         { build(:user, subscribed: true) }
      let(:subscription) { described_class.new(user) }

      before do
        Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "subscribes users" do
        interface.should_receive(:subscribe).with(user.email, {'SIZE' => '10', 'HEIGHT' => '20'}, customer: true)
        user.save
      end
    end

    context "subscribing subscribers" do
      let(:subscriber)   { Spree::Chimpy::Subscriber.new(email: "test@example.com", subscribed: true) }
      let(:subscription) { described_class.new(subscriber) }

      it "subscribes subscribers" do
        interface.should_receive(:subscribe).with(subscriber.email, {}, customer: false)
        interface.should_not_receive(:segment)
        subscriber.save
      end
    end

    context "resubscribe" do
      let(:user)         { create(:user, subscribed: true) }
      let(:subscription) { double(:subscription) }

      before do
        interface.should_receive(:subscribe).once.with(user.email)
        user.stub(subscription: subscription)
      end

      context "when update needed" do
        it "calls resubscribe" do
          subscription.should_receive(:resubscribe)
          user.save
        end
      end

      context "when update not needed" do
        it "still calls resubscribe, and does nothing" do
          subscription.should_receive(:resubscribe)
          subscription.should_not_receive(:unsubscribe)
          user.save
        end
      end
    end

    context "unsubscribing" do
      let(:subscription) { described_class.new(user) }

      before { interface.stub(:subscribe) }

      context "subscribed user" do
        let(:user) { create(:user, subscribed: true) }
        it "unsubscribes" do
          interface.should_receive(:unsubscribe).with(user.email)
          user.subscribed = false
          subscription.unsubscribe
        end
      end

      context "non-subscribed user" do
        let(:user) { build(:user, subscribed: false) }
        it "does nothing" do
          interface.should_not_receive(:unsubscribe)
          subscription.unsubscribe
        end
      end
    end

    context "when an existing user is not already subscribed" do
      let(:user) { create(:user, subscribed: false) }
      let(:subscription) { described_class.new(user) }

      context "#resubscribe" do
        it "subscribes the user" do
          interface.should_receive(:subscribe).with(user.email, {}, {customer: true})
          user.subscribed = true
          subscription.resubscribe
        end
      end
    end

    context "when an existing user is already subscribed" do
      let(:user) { create(:user, subscribed: true) }
      let(:subscription) { described_class.new(user) }

      before { interface.stub(:subscribe) }

      context "#resubscribe" do
        it "unsubscribes the user" do
          interface.should_receive(:unsubscribe).with(user.email)
          user.subscribed = false
          subscription.resubscribe
        end

        context "merge vars changed" do
          let(:user) { create(:user, subscribed: true, size: 10, height: 20) }

          before do
            Spree::Chimpy::Config.merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

            Spree::User.class_eval do
              attr_accessor :size, :height
            end
          end

          it "subscribes the user once again" do
            user.size += 5
            user.height += 10
            interface.should_receive(:subscribe).with(user.email, {"SIZE"=> user.size.to_s, "HEIGHT"=> user.height.to_s}, {:customer=>true})
            subscription.resubscribe
          end
        end
      end
    end

    context "when updating a user and not changing subscription details" do
      it "does not update mailchimp" do
        interface.stub(:subscribe)
        user = create(:user, subscribed: true)

        interface.should_not_receive(:subscribe)
        user.spree_api_key = 'something'
        user.save!
      end
    end

  end

  context "mail chimp disabled" do
    before do
      Spree::Chimpy::Config.stub(key: nil)

      user = build(:user, subscribed: true)
      @subscription = described_class.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.resubscribe {} }
  end

end

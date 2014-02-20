module Spree::Chimpy
  class Subscription
    delegate :configured?, :enqueue, to: Spree::Chimpy

    def initialize(user)
      @user      = user
    end

    def subscribe(source = nil)
      chimpy_action = Spree::Chimpy::Action.new(email: @user.email, source: source, action: :subscribe)
      if !@user.subscribed? && chimpy_action.save
        @user.update_column(:subscribed, true)
        defer(:subscribe)
        true
      else
        false
      end
    end

    def update_member_info
      if @user.subscribed?
        defer(:subscribe)
      end
    end

    def unsubscribe(source = nil)
      chimpy_action = Spree::Chimpy::Action.new(email: @user.email, source: source, action: :unsubscribe)
      if @user.subscribed? && chimpy_action.save
        @user.update_column(:subscribed, false)
        defer(:unsubscribe) 
        true
      else
        false
      end
    end


  private
    def defer(event)
      enqueue(event, @user)
    end

  end
end

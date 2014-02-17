module Spree::Chimpy
  class Subscription
    delegate :configured?, :enqueue, to: Spree::Chimpy

    def initialize(model)
      @model      = model
    end

    def subscribe
      defer(:subscribe)
    end

    def unsubscribe
      defer(:unsubscribe) if @model.subscribed?
    end

    def resubscribe(&block)
      block.call if block

      return unless configured?
      if unsubscribing?
        unsubscribe
      elsif subscribing?
        subscribe
      end
    end

  private
    def defer(event)
      enqueue(event, @model)
    end

    def subscribing?
      @model.subscribed
    end

    def unsubscribing?
      !@new_record && !@model.subscribed && @model.subscribed_changed?
    end

  end
end

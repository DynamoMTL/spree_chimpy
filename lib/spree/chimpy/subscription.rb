module Spree::Chimpy
  class Subscription
    def initialize(model)
      @model      = model
      @interface  = Spree::Chimpy.list
    end

    def subscribe
      Spree::Chimpy.enqueue(:subscribe, @model) if allowed?
    end

    def unsubscribe
      Spree::Chimpy.enqueue(:unsubscribe, @model) if allowed?
    end

    def resubscribe(&block)
      block.call if block

      return unless configured?

      if unsubscribing?
        unsubscribe
      elsif subscribing? || merge_vars_changed?
        subscribe
      end
    end

  private
    def configured?
      Spree::Chimpy.configured?
    end

    def allowed?
      configured? && @model.subscribed
    end

    def subscribing?
      merge_vars_changed? && @model.subscribed
    end

    def unsubscribing?
      !@new_record && !@model.subscribed && @model.subscribed_changed?
    end

    def merge_vars_changed?
      Config.preferred_merge_vars.values.any? do |attr|
        @model.send("#{attr}_changed?")
      end
    end
  end
end

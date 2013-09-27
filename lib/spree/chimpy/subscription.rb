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
      defer(:unsubscribe)
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
    def defer(event)
      enqueue(event, @model) if allowed?
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
      Config.merge_vars.values.any? do |attr|
        name = "#{attr}_changed?".to_sym
        !@model.methods.include?(name) || @model.send(name)
      end
    end
  end
end

module Spree::Chimpy
  class Subscription
    def initialize(model)
      @model      = model
      @changes    = model.changes.dup
      @interface  = Config.list
    end

    def needs_update?
      update_allowed? && (merge_vars_changed? || unsubscribing?)
    end

    def subscribe
      if update_allowed?
        @interface.subscribe(@model.email, merge_vars)
        @interface.segment_emails([@model.email]) if @model.kind_of? Spree.user_class
      end
    end

    def unsubscribe
      @interface.unsubscribe(@model.email) if update_allowed?
    end

    def resubscribe(&block)
      block.call

      if unsubscribing?
        unsubscribe
      elsif subscribing? || merge_vars_changed?
        subscribe
      end
    end

  private
    def subscribing?
      @model.new_record? && @model.subscribed
    end

    def unsubscribing?
      @model.persisted? && !@model.subscribed && @model.subscribed_changed?
    end

    def update_allowed?
      @interface && (@model.subscribed || unsubscribing?)
    end

    def merge_vars_changed?
      Config.preferred_merge_vars.values.any? do |attr|
        @model.send("#{attr}_changed?")
      end
    end

    def merge_vars
      array = Config.preferred_merge_vars.except('EMAIL').map do |tag, method|
        [tag, @model.send(method)]
      end

      Hash[array]
    end
  end
end

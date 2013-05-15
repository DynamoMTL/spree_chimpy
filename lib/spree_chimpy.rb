require 'spree_core'
require 'spree/chimpy/engine'
require 'spree/chimpy/subscription'
require 'spree/chimpy/workers/delayed_job'
require 'hominid'

module Spree::Chimpy
  extend self

  API_VERSION = '1.3'

  def config(&block)
    yield(Spree::Chimpy::Config)
  end

  def enqueue(event, object)
    payload = {class: object.class.name, id: object.id, object: object}
    ActiveSupport::Notifications.instrument("spree.chimpy.#{event}", payload)
  end

  def log(message)
    Rails.logger.info "spree_chimpy: #{message}"
  end

  def configured?
    Config.preferred_key.present?
  end

  def list
    Interface::List.new(Config.preferred_key,
                        Config.preferred_list_name,
                        Config.preferred_customer_segment_name) if configured?
  end

  def orders
    Interface::Orders.new(Config.preferred_key) if configured?
  end

  def list_exists?
    list.list_id
  end

  def segment_exists?
    list.segment_id
  end

  def create_segment
    list.create_segment
  end

  def sync_merge_vars
    existing   = list.merge_vars + %w(EMAIL)
    merge_vars = Config.preferred_merge_vars.except(*existing)

    merge_vars.each do |tag, method|
      list.add_merge_var(tag.upcase, method.to_s.humanize.titleize)
    end
  end

  def merge_vars(model)
    array = Config.preferred_merge_vars.except('EMAIL').map do |tag, method|
      [tag, model.send(method).to_s]
    end

    Hash[array]
  end

  def handle_event(event, payload = {})
    payload[:event] = event

    if defined?(::Delayed::Job)
      ::Delayed::Job.enqueue(Spree::Chimpy::Workers::DelayedJob.new(payload))
    else
      perform(payload)
    end
  end

  def perform(payload)
    return unless configured?

    event  = payload[:event].to_sym
    object = payload[:object] || payload[:class].constantize.find(payload[:id])

    if !object
      raise Error.new("Unable to locate a #{payload[:class]} with id #{payload[:id]}")
    end

    case event
    when :order
      orders.sync(object)
    when :subscribe
      list.subscribe(object.email, merge_vars(object), customer: object.is_a?(Spree.user_class))
    when :unsubscribe
      list.unsubscribe(object.email)
    end
  end
end

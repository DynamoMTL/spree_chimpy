require 'spree_core'
require 'spree/chimpy/engine'
require 'spree/chimpy/subscription'
require 'hominid'

module Spree::Chimpy
  extend self

  API_VERSION = '1.3'

  def config(&block)
    yield(Spree::Chimpy::Config)
  end

  def fire_event(event, payload={})
    ActiveSupport::Notifications.instrument("spree.chimpy.#{event}", payload)
  end

  def log(message)
    Rails.logger.info "spree_chimpy: #{message}"
  end

  def configured?
    Config.preferred_key.present?
  end

  def list
    Interface::List.new(Config.preferred_key, Config.preferred_list_name) if configured?
  end

  def orders
    Interface::Orders.new(Config.preferred_key) if configured?
  end

  def list_exists?
    list.find_list_id(Config.preferred_list_name)
  end

  def sync_merge_vars
    existing   = list.merge_vars + %w(EMAIL)
    merge_vars = Config.preferred_merge_vars.except(*existing)

    merge_vars.each do |tag, method|
      list.add_merge_var(tag.upcase, method.to_s.humanize.titleize)
    end
  end

end

require 'spree_core'
require 'spree/chimpy/engine'
require 'spree/chimpy/subscription'
require 'hominid'

module Spree::Chimpy
  API_VERSION = '1.3'

  def self.config(&block)
    yield(Spree::Chimpy::Config)
  end

  def self.fire_event(event, payload={})
    ActiveSupport::Notifications.instrument("spree.chimpy.#{event}", payload)
  end
end

require 'spree_core'
require 'spree/chimpy/engine'
require 'spree/chimpy/subscription'
require 'hominid'

module Spree::Chimpy
  def self.config(&block)
    yield(Spree::Chimpy::Config)
  end
end

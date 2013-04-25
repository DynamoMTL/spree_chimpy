require 'spree_core'
require 'spree/hominid/engine'
require 'spree/hominid/subscription'
require 'hominid'

module Spree::Hominid
  def self.config(&block)
    yield(Spree::Hominid::Config)
  end
end

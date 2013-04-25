require 'spree_core'
require 'spree_hominid/engine'
require 'spree_hominid/subscription'
require 'hominid'

module SpreeHominid
  def self.config(&block)
    yield(SpreeHominid::Config)
  end
end

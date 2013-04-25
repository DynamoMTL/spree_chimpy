require 'spec_helper'

describe Spree::Order do
  it "has a source" do
    order = Spree::Order.new
    order.should respond_to(:source)
  end
end

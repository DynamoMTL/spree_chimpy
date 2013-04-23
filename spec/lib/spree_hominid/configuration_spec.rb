require 'spec_helper'

describe SpreeHominid::Configuration do
  it "knows when its enabled" do
    config(key: '1234').should be_enabled
  end

  it "knows when its disabled" do
    config(key: nil).should_not be_enabled
  end

  def config(options = {})
    config = SpreeHominid::Configuration.new
    config.preferred_key = options[:key]
    config
  end
end

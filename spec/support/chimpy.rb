RSpec.configure do |config|

  config.before do
    Spree::Chimpy.reset
  end
end
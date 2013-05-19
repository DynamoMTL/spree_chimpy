module Spree::Chimpy
  module Workers
    class Sidekiq
      include ::Spree::Chimpy
      
      if defined?(::Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :queue => :mailchimp
      end

    end
  end
end
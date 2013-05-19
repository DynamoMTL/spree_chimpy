module Spree::Chimpy
  module Workers
    class Sidekiq
      if defined?(::Sidekiq)
        include ::Sidekiq::Worker
        sidekiq_options :unique => true, :queue => :spee_chimpy
      end

      def perform(payload)
        Spee::Chimpy.perform(paylod)
      end
      
    end
  end
end
module Spree::Chimpy
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_chimpy'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree_chimpy.environment", before: :load_config_initializers do |app|
      Spree::Chimpy::Config = Spree::Chimpy::Configuration.new
    end

    initializer 'spree_chimpy.check_list_name' do
      if !Rails.env.test? && Spree::Chimpy.configured?
        list_name = Spree::Chimpy::Config.list_name

        if Spree::Chimpy.list_exists?
          Spree::Chimpy.sync_merge_vars
        else
          Rails.logger.error("spree_chimpy: hmm.. a list named `#{list_name}` was not found. please add it and reboot the app")
        end
      end
    end

    initializer 'spree_chimpy.check_segment_name' do
      if !Rails.env.test? && Spree::Chimpy.configured?
        segment_name = Spree::Chimpy::Config.customer_segment_name

        unless Spree::Chimpy.segment_exists?
          Spree::Chimpy.create_segment
          Rails.logger.error("spree_chimpy: hmm.. a static segment named `#{segment_name}` was not found. Creating it now")
        end
      end
    end
    
    initializer 'spree_chimpy.double_opt_in' do
      if Spree::Chimpy::Config.subscribed_by_default && !Spree::Chimpy::Config.double_opt_in
        Rails.logger.warn("spree_chimpy: You have 'subscribed by default' enabled while 'double opt-in' is disabled. This is not recommended.")
      end
    end

    initializer 'spree_chimpy.subscribe' do
      ActiveSupport::Notifications.subscribe /^spree\.chimpy\./ do |name, start, finish, id, payload|
        Spree::Chimpy.handle_event(name.split('.').last, payload)
      end
    end

    def self.activate
      Spree::StoreController.send(:include, Spree::Chimpy::ControllerFilters)

      Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end

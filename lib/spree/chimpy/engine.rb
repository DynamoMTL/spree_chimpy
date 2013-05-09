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

    initializer "spree.hominid.environment", before: :load_config_initializers do |app|
      Spree::Chimpy::Config = Spree::Chimpy::Configuration.new
    end

    initializer 'spree_chimpy.check_list_name' do
      if !Rails.env.test? && Config.configured?
        list_name = Spree::Chimpy::Config.preferred_list_name

        if Config.list_exists?
          Config.sync_merge_vars
        else
          Rails.logger.error("spree_chimpy: hmm.. a list named `#{list_name}` was not found. please add it and reboot the app")
        end
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

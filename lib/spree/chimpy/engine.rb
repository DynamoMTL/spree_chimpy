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

    initializer 'spree_chimpy.ensure' do
      if !Rails.env.test? && Spree::Chimpy.configured?
        Spree::Chimpy.ensure_list
        Spree::Chimpy.ensure_segment
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

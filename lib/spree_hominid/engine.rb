module SpreeHominid
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace SpreeHominid
    engine_name 'spree_hominid'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_hominid.configuration', before: 'spree.environment' do
      module ::SpreeHominid
        Config = Configuration.new
      end
    end

    initializer 'spree_hominid.check_list_name' do
      if Config.enabled?
        list_name = SpreeHominid::Config.preferred_list_name
        Rails.logger.error("spree_hominid: hmm.. a list named `#{list_name}` was not found. please add it and reboot the app") unless Config.list_exists?
      end
    end

    def self.activate
      Spree::BaseController.send(:include, SpreeHominid::ControllerFilters)

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end

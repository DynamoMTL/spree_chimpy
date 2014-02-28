module SpreeChimpy
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../templates/', __FILE__)

      def copy_initializer_file
        copy_file 'spree_chimpy.rb', "config/initializers/spree_chimpy.rb"
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_chimpy'
      end

      def run_migrations
         run 'bundle exec rake db:migrate'
      end
    end
  end
end

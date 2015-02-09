require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Overrides', 'app/overrides'
  add_group 'Libraries', 'lib'
end

ENV['RAILS_ENV'] = 'test'


require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'spree/testing_support/url_helpers'

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'shoulda-matchers'
require 'ffaker'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end


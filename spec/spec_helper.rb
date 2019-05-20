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
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'shoulda-matchers'
require 'ffaker'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Excon.defaults[:ssl_verify_peer] = false


Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end

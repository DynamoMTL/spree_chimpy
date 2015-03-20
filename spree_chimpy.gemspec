# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_chimpy'
  s.version     = '2.0.0.alpha'
  s.summary     = 'MailChimp/Spree integration using the mailchimp gem'
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Joshua Nussbaum'
  s.email     = 'josh@godynamo.com'
  s.homepage  = 'http://www.godynamo.com'
  s.license   = %q{BSD-3}

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1'
  s.add_dependency 'mailchimp-api', '~> 2.0.5'

  s.add_development_dependency 'rspec-rails', '~> 2.14'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'capybara', '~> 2.2.1'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'shoulda-matchers', '~> 2.5'
  s.add_development_dependency 'sqlite3', '~> 1.3.9'
  s.add_development_dependency 'simplecov', '0.7.1'
  s.add_development_dependency 'database_cleaner', '1.2.0'
  s.add_development_dependency 'coffee-rails', '~> 4.0.1'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'launchy'
end

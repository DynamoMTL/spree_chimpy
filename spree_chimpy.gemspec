# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_chimpy'
  s.version     = '1.3.3'
  s.summary     = 'mailchimp/spree integration using the hominid gem'
  s.description = ''
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Joshua Nussbaum'
  s.email     = 'josh@godynamo.com'
  s.homepage  = 'http://www.godynamo.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.2'
  s.add_dependency 'mailchimp-api'
  
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
end

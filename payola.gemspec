$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "payola/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "payola-payments"
  s.version     = Payola::VERSION
  s.authors     = ["Pete Keen"]
  s.email       = ["pete@payola.io"]
  s.homepage    = "https://www.payola.io"
  s.summary     = "Drop-in Rails engine for accepting payments with Stripe"
  s.description = "One-off and subscription payments for your Rails application"
  s.license     = "LGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "stripe", ">= 1.16.0"
  s.add_dependency "aasm", "~> 3.4.0"
  s.add_dependency "stripe_event", "~> 1.3.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency "stripe-ruby-mock", "~> 1.10.1.7"
  s.add_development_dependency "sucker_punch", "~> 1.2.1"
end

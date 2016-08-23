$:.push File.expand_path("../lib", __FILE__)

require "payola/version"

Gem::Specification.new do |s|
  s.name        = "payola-payments"
  s.version     = Payola::VERSION
  s.authors     = ["Pete Keen"]
  s.email       = ["pete@payola.io"]
  s.homepage    = "https://www.payola.io"
  s.summary     = "Drop-in Rails engine for accepting payments with Stripe"
  s.description = "One-off and subscription payments for your Rails application"
  s.license     = "LGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "stripe"
  s.add_dependency "aasm", ">= 4.0.7"
  s.add_dependency "stripe_event", ">= 1.3.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "stripe-ruby-mock", "2.1.0"
  s.add_development_dependency "sucker_punch", "~> 1.2.1"
  s.add_development_dependency "docverter"
end

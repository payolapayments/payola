module Payola
  class Engine < ::Rails::Engine
    isolate_namespace Payola
    engine_name 'payola'

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end

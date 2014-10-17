module Payola
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def install_initializer
      initializer 'payola.rb', File.read(File.expand_path('../templates/initializer.rb', __FILE__))
    end
  end
end

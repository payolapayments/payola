module Payola
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def install_initializer
      initializer 'payola.rb', File.read(File.expand_path('../templates/initializer.rb', __FILE__))
    end

    def install_js
      inject_into_file 'app/assets/javascripts/application.js', after: "//= require jquery\n" do <<-'JS'
//= require payola
      JS
      end
    end

    def install_route
      route "mount Payola::Engine => '/payola', as: :payola"
    end
  end
end

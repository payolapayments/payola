begin
  require 'sidekiq'
rescue LoadError
end

module Payola
  module Worker
    class Sidekiq < BaseWorker
      include ::Sidekiq::Worker if defined? ::Sidekiq::Worker

      def self.can_run?
        defined?(::Sidekiq::Worker)
      end

      def self.call(klass, *args)
        perform_async(klass.to_s, *args)
      end
    end
  end
end

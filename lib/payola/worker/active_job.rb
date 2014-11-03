module ::ActiveJob
  class Base; end
end

module Payola
  module Worker
    class ActiveJob < ::ActiveJob::Base
      def self.can_run?
        defined?(::ActiveJob::Core)
      end

      def self.call(klass, *args)
        perform_later(klass.to_s, *args)
      end
  
      def perform(klass, *args)
        klass.safe_constantize.call(*args)
      end
    end
  end
end

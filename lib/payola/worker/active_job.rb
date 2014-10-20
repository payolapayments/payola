module ::ActiveJob
  class Base; end
end

module Payola
  module Worker
    class ActiveJob < ::ActiveJob::Base
      def self.can_run?
        defined?(::ActiveJob::Core)
      end

      def self.call(sale)
        perform_later(sale.guid)
      end
  
      def perform(guid)
        Sale.where(guid: guid).first.process!
      end
    end
  end
end

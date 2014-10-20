begin
  require 'sucker_punch'
rescue LoadError
end

module Payola
  module Worker
    class SuckerPunch < BaseWorker
      include ::SuckerPunch::Job  if defined? ::SuckerPunch::Job

      def self.can_run?
        defined?(::SuckerPunch::Job)
      end

      def self.call(sale)
        new.async.perform(sale.guid)
      end
    end
  end
end

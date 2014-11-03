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

      def self.call(klass, *args)
        new.async.perform(klass.to_s, *args)
      end
    end
  end
end

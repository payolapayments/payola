module Payola
  module Worker
    class << self
      attr_accessor :registry

      def find(symbol)
        if registry.has_key? symbol
          return registry[symbol]
        else
          raise "No such worker type: #{symbol}"
        end
      end

      def autofind
        registry.values.each do |worker|
          if worker.can_run?
            return worker
          end
        end

        raise "No eligable background worker systems found."
      end
    end

    class BaseWorker
      def perform(guid)
        Sale.where(guid: guid).first.process!
      end
    end

    class Sidekiq < BaseWorker
      include ::Sidekiq::Worker if defined? ::Sidekiq::Worker

      def self.can_run?
        defined?(::Sidekiq::Worker)
      end

      def self.call(sale)
        self.perform_async(sale.guid)
      end
    end

    class SuckerPunch < BaseWorker
      include ::SuckerPunch::Job  if defined? ::SuckerPunch::Job

      def self.can_run?
        defined?(::SuckerPunch::Job)
      end

      def self.call(sale)
        self.new.async.perform(sale.guid)
      end
    end

    self.registry = {
      sidekiq: Payola::Worker::Sidekiq,
      sucker_punch: Payola::Worker::SuckerPunch
    }
  end
end

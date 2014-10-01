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

    class Sidekiq
      def self.can_run?
        defined?(::Sidekiq::Worker)
      end

      def self.call(sale)
        self.send(:include, ::Sidekiq::Worker)
        self.perform_async(sale.guid)
      end
    end

    registry = {
      sidekiq: Payola::Worker::Sidekiq
    }
  end
end

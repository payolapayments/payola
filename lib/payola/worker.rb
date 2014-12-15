require 'payola/worker/base'
require 'payola/worker/active_job'
require 'payola/worker/sidekiq'
require 'payola/worker/sucker_punch'

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
        # prefer ActiveJob over the other workers
        if Payola::Worker::ActiveJob.can_run?
          return Payola::Worker::ActiveJob
        end
        
        registry.values.each do |worker|
          if worker.can_run?
            return worker
          end
        end

        raise "No eligible background worker systems found."
      end
    end

    self.registry = {
      sidekiq:      Payola::Worker::Sidekiq,
      sucker_punch: Payola::Worker::SuckerPunch,
      active_job:   Payola::Worker::ActiveJob
    }
  end
end

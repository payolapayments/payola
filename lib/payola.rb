require "payola/engine"
require "payola/worker"

module Payola
  class << self
    attr_accessor :publishable_key, :secret_key, :secret_key_retriever, :background_worker

    def configure(&block)
      raise ArgumentError, "must provide a block" unless block_given?
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end

    def secret_key_for_sale(sale)
      return secret_key_retriever.call(sale)
    end

    def subscribe(name, callable = Proc.new)
      StripeEvent.subscribe(name, callable)
    end

    def instrument(name, object)
      StripeEvent.backend.instrument(StripeEvent.namespace.call(name), object)
    end

    def all(callable = Proc.new)
      StripeEvent.all(callable)
    end

    def queue!(sale)
      if background_worker.is_a? Symbol
        Payola::Worker.find(:symbol).call(sale)
      elsif background_worker.respond_to?(:call)
        background_worker.call(sale)
      else
        Payola::Worker.autofind.call(sale)
      end
    end
  end

  self.publishable_key = ENV['STIRPE_PUBLISHABLE_KEY']
  self.secret_key = ENV['STRIPE_SECRET_KEY']
  self.secret_key_retriever = lambda { |sale| Payola.secret_key }
end

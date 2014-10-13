require "payola/engine"
require "payola/worker"
require 'stripe_event'
require 'jquery-rails'

module Payola
  class << self
    attr_accessor :publishable_key, :secret_key, :secret_key_retriever, :background_worker, :event_filter, :support_email, :sellables

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
        Payola::Worker.find(background_worker).call(sale)
      elsif background_worker.respond_to?(:call)
        background_worker.call(sale)
      else
        Payola::Worker.autofind.call(sale)
      end
    end

    def reset!
      StripeEvent.event_retriever = Retriever

      self.background_worker = nil
      self.event_filter = lambda { |event| event }
      self.publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
      self.secret_key = ENV['STRIPE_SECRET_KEY']
      self.secret_key_retriever = lambda { |sale| Payola.secret_key }
      self.support_email = 'sales@example.com'
      self.sellables = {}
    end

    def register_sellable(klass)
      sellables[klass.product_class] = klass
    end
  end

  class Retriever
    def self.call(params)
      return nil if StripeWebhook.exists?(stripe_id: params[:id])
      StripeWebhook.create!(stripe_id: params[:id])
      event = Stripe::Event.retrieve(params[:id], Payola.secret_key)
      Payola.event_filter.call(event)
    end
  end

  self.reset!
end

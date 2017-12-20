require 'payola/version'
require "payola/engine"
require "payola/worker"
require 'stripe_event'
require 'jquery-rails'

module Payola

  DEFAULT_EMAILS = {
    receipt:       [ 'payola.sale.finished', 'Payola::ReceiptMailer', :receipt ],
    refund:        [ 'charge.refunded',      'Payola::ReceiptMailer', :refund  ],
    admin_receipt: [ 'payola.sale.finished', 'Payola::AdminMailer',   :receipt ],
    admin_dispute: [ 'dispute.created',      'Payola::AdminMailer',   :dispute ],
    admin_refund:  [ 'payola.sale.refunded', 'Payola::AdminMailer',   :refund  ],
    admin_failure: [ 'payola.sale.failed',   'Payola::AdminMailer',   :failure ],
  }

  class << self
    attr_accessor :publishable_key,
      :publishable_key_retriever,
      :secret_key,
      :secret_key_retriever,
      :background_worker,
      :event_filter,
      :support_email,
      :sellables,
      :subscribables,
      :charge_verifier,
      :default_currency,
      :default_tax_percent,
      :additional_charge_attributes,
      :guid_generator,
      :pdf_receipt,
      :create_stripe_plans

    def configure(&block)
      raise ArgumentError, "must provide a block" unless block_given?
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end

    def secret_key_for_sale(sale)
      return secret_key_retriever.call(sale).to_s
    end

    def publishable_key_for_sale(sale)
      return publishable_key_retriever.call(sale).to_s
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

    def queue!(klass, *args)
      if background_worker.is_a? Symbol
        Payola::Worker.find(background_worker).call(klass, *args)
      elsif background_worker.respond_to?(:call)
        background_worker.call(klass, *args)
      else
        Payola::Worker.autofind.call(klass, *args)
      end
    end

    def send_mail(mailer, method, *args)
      Payola.queue!(Payola::SendMail, mailer.to_s, method.to_s, *args)
    end

    def reset!
      StripeEvent.event_filter = Retriever
      Stripe.api_version = ENV['STRIPE_API_VERSION'] || '2015-02-18'

      self.background_worker = nil
      self.event_filter = lambda { |event| event }
      self.charge_verifier = lambda { |event| true }
      self.publishable_key = EnvWrapper.new('STRIPE_PUBLISHABLE_KEY')
      self.secret_key = EnvWrapper.new('STRIPE_SECRET_KEY')
      self.secret_key_retriever = lambda { |sale| Payola.secret_key  }
      self.publishable_key_retriever = lambda { |sale| Payola.publishable_key }
      self.support_email = 'sales@example.com'
      self.default_currency = 'usd'
      self.default_tax_percent = nil
      self.sellables = {}
      self.subscribables = {}
      self.additional_charge_attributes = lambda { |sale, customer| { } }
      self.pdf_receipt = false
      self.guid_generator = lambda { SecureRandom.random_number(1_000_000_000).to_s(32) }
      self.create_stripe_plans = true
    end

    def register_sellable(klass)
      sellables[klass.product_class] = klass
    end

    def register_subscribable(klass)
      subscribables[klass.plan_class] = klass
    end

    def send_email_for(*emails)
      emails.each do |email|
        spec = DEFAULT_EMAILS[email].dup
        if spec
          Payola.subscribe(spec.shift) do |sale|
            if sale.is_a?(Stripe::Event)
              sale = Payola::Sale.find_by!(stripe_id: sale.data.object.id)
            end

            Payola.send_mail(*(spec + [sale.guid]))
          end
        end
      end
    end
  end

  class Retriever
    def self.call(params)
      return nil if StripeWebhook.exists?(stripe_id: params[:id])
      StripeWebhook.create!(stripe_id: params[:id])
      event = Stripe::Event.retrieve(params[:id], { api_key: Payola.secret_key })
      Payola.event_filter.call(event)
    end
  end

  class EnvWrapper
    def initialize(key)
      @key = key
    end

    def to_s
      ENV[@key]
    end

    def ==(other)
      to_s == other.to_s
    end

    # This is a nasty hack to counteract Stripe checking if the API key is_a String
    # See https://github.com/peterkeen/payola/issues/256 for details
    def is_a?(other)
      ENV[@key].is_a?(other)
    end
  end

  self.reset!
end

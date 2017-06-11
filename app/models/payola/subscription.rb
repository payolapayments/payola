require 'aasm'

module Payola
  class Subscription < ActiveRecord::Base
    include Payola::GuidBehavior

    has_paper_trail if respond_to? :has_paper_trail

    validates_presence_of :email
    validates_presence_of :plan_id
    validates_presence_of :plan_type

    validate :conditional_stripe_token
    validates_presence_of :currency

    belongs_to :plan, Rails::VERSION::MAJOR > 4 ? { polymorphic: true, optional: true } : { polymorphic: true }
    belongs_to :owner, Rails::VERSION::MAJOR > 4 ? { polymorphic: true, optional: true } : { polymorphic: true }
    belongs_to :affiliate, Rails::VERSION::MAJOR > 4 ? { optional: true } : {}

    has_many :sales, class_name: 'Payola::Sale', as: :owner

    include AASM

    attr_accessor :old_plan, :old_quantity

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :processing
      state :active
      state :canceled
      state :errored

      event :process, after: :start_subscription do
        transitions from: :pending, to: :processing
      end

      event :activate, after: :instrument_activate do
        transitions from: :processing, to: :active
      end

      event :cancel, after: :instrument_canceled do
        transitions from: :active, to: :canceled
      end

      event :fail, after: :instrument_fail do
        transitions from: [:pending, :processing], to: :errored
      end

      event :refund, after: :instrument_refund do
        transitions from: :finished, to: :refunded
      end
    end

    def name
      self.plan.name
    end

    def price
      self.plan.amount
    end

    def redirect_path(sale)
      self.plan.redirect_path(self)
    end

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Payola.secret_key_for_sale(self), digest: 'SHA256')
    end

    def verify_charge
      begin
        self.verify_charge!
      rescue RuntimeError => e
        self.error = e.message
        self.fail!
      end
    end

    def verify_charge!
      if Payola.charge_verifier.arity > 1
        Payola.charge_verifier.call(self, custom_fields)
      else
        Payola.charge_verifier.call(self)
      end
    end

    def custom_fields
      if self.signed_custom_fields.present?
        verifier.verify(self.signed_custom_fields)
      else
        nil
      end
    end

    def sync_with!(stripe_sub)
      self.current_period_start = Time.at(stripe_sub.current_period_start)
      self.current_period_end   = Time.at(stripe_sub.current_period_end)
      self.ended_at             = Time.at(stripe_sub.ended_at) if stripe_sub.ended_at
      self.trial_start          = Time.at(stripe_sub.trial_start) if stripe_sub.trial_start
      self.trial_end            = Time.at(stripe_sub.trial_end) if stripe_sub.trial_end
      self.canceled_at          = Time.at(stripe_sub.canceled_at) if stripe_sub.canceled_at
      self.quantity             = stripe_sub.quantity
      self.stripe_status        = stripe_sub.status
      self.amount               = stripe_sub.plan.amount
      self.currency             = stripe_sub.plan.respond_to?(:currency) ? stripe_sub.plan.currency : Payola.default_currency
      self.cancel_at_period_end = stripe_sub.cancel_at_period_end

      # Support for discounts is added to stripe-ruby-mock in v2.2.0, 84f08eb
      self.coupon               = stripe_sub.discount && stripe_sub.discount.coupon.id if stripe_sub.respond_to?(:discount)

      self.save!
      self
    end

    def to_param
      guid
    end

    def instrument_plan_changed(old_plan)
      self.old_plan = old_plan
      Payola.instrument(instrument_key('plan_changed'), self)
      Payola.instrument(instrument_key('plan_changed', false), self)
    end

    def instrument_quantity_changed(old_quantity)
      self.old_quantity = old_quantity
      Payola.instrument(instrument_key('quantity_changed'), self)
      Payola.instrument(instrument_key('quantity_changed', false), self)
    end

    def redirector
      plan
    end

    def conditional_stripe_token
      # Don't require a Stripe token if the subscription has an owner - we'll try to reuse the Stripe customer from an existing successful subscription
      return true if owner.present?
      # Don't require a Stripe token if we're creating a subscription for an existing Stripe customer
      return true if stripe_customer_id.present?
      return true if plan.nil?
      if (plan.amount > 0 )
        if plan.respond_to?(:trial_period_days) and (plan.trial_period_days.nil? or ( plan.trial_period_days and !(plan.trial_period_days > 0) ))
          errors.add(:base, 'No Stripe token is present for a paid plan') if stripe_token.nil?
        end
      end
    end

    private

    def start_subscription
      Payola::StartSubscription.call(self)
    end

    def instrument_activate
      Payola.instrument(instrument_key('active'), self)
      Payola.instrument(instrument_key('active', false), self)
    end

    def instrument_canceled
      Payola.instrument(instrument_key('canceled'), self)
      Payola.instrument(instrument_key('canceled', false), self)
    end

    def instrument_fail
      Payola.instrument(instrument_key('failed'), self)
      Payola.instrument(instrument_key('failed', false), self)
    end

    def instrument_refund
      Payola.instrument(instrument_key('refunded'), self)
      Payola.instrument(instrument_key('refunded', false), self)
    end

    def instrument_key(instrument_type, include_class=true)
      if include_class
        "payola.#{plan_type}.subscription.#{instrument_type}"
      else
        "payola.subscription.#{instrument_type}"
      end
    end

  end
end

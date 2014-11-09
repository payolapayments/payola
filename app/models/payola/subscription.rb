require 'aasm'

module Payola
  class Subscription < ActiveRecord::Base

    validates_presence_of :email
    validates_presence_of :plan_id
    validates_presence_of :plan_type
    validates_presence_of :stripe_token
    validates_presence_of :currency

    validates_uniqueness_of :guid

    before_save :populate_guid

    belongs_to :plan,  polymorphic: true
    belongs_to :owner, polymorphic: true

    has_many :sales, class_name: 'Payola::Sale'

    include AASM

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :processing
      state :finished
      state :errored
      state :refunded

      event :process, after: :start_subscription do
        transitions from: :pending, to: :processing
      end

      event :finish, after: :instrument_finish do
        transitions from: :processing, to: :finished
      end

      event :fail, after: :instrument_fail do
        transitions from: [:pending, :processing], to: :errored
      end

      event :refund, after: :instrument_refund do
        transitions from: :finished, to: :refunded
      end
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


    private

    def start_subscription
      Payola::StartSubscription.call(self)
    end

    def instrument_finish
      Payola.instrument(instrument_key('finished'), self)
      Payola.instrument(instrument_key('finished', false), self)
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

    def populate_guid
      if new_record?
        while !valid? || self.guid.nil?
          self.guid = SecureRandom.random_number(1_000_000_000).to_s(32)
        end
      end
    end


    
  end
end

module Payola
  class Subscription < ActiveRecord::Base
    has_paper_trail if respond_to? :has_paper_trail

    validates_presence_of :email
    validates_presence_of :plan_id
    validates_presence_of :plan_type
    validates_presence_of :stripe_token

    validates_uniqueness_of :guid

    before_save :populate_guid

    belongs_to :plan, polymorphic: true
    belongs_to :subscribable, polymorphic: true

    belongs_to :affiliate

    include AASM

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :processing
      state :current
      state :cancelled
      state :errored

      event :process, after: :start_subscription do
        transitions from: :pending, to: :processing
      end

      event :finish, after: :instrument_finish do
        transitions from: :processing, to :current
      end

      event :fail, after: :instrument_fail do
        transitions from: [:pending, :processing], to: :errored
      end

      event :cancel, after: :cancel_subscription do
        transitions from:finished, to: :cancelled
      end

      event :change, after: :change_subscription do
        transitions from: :current, to: :processing
      end
    end

    private

    def start_subscription do
      sub, customer = Payola::StartSubscription.call(self)
      Payola.instrumet(instrument_key('started'), sub, customer)
    end

    def cancel_subscription
      Payola::CancelSubscription.call(self)
      Payola.instrument(instrument_key('cancel'), self)
    end

    def change_subscription
      Payola::ChangeSubscription.call(self)
      Payola.instrument(instrument_key('change'), self)
    end

    def instrument_finish
      Payola.instrument(instrument_key('finished'), self)
    end

    def instrument_fail
      Payola.instrument(instrument_key('failed'), self)
    end

    def instrument_key(instrument_type)
      "payola.subscription.#{instrument_type}"
    end
    
    def populate_guid
      if new_record?
        while !valid? || self.guid.nil?
          self.guid = SecureRandom.random_number(1_000_000_000).to_s(32)
        end
      end
    end

    def product_class
      'subscription'
    end
  end
end

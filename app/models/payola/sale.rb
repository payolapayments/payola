module Payola
  class Sale < ActiveRecord::Base
    has_paper_trail if respond_to? :has_paper_trail

    validates_presence_of :email
    validates_presence_of :product_id
    validates_presence_of :stripe_token

    validates_uniqueness_of :guid

    before_save :populate_guid

    belongs_to :product
    belongs_to :coupon
    belongs_to :affiliate

    include AASM

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :processing
      state :finished
      state :errored
      state :refunded

      event :process, after: :charge_card do
        transitions from: :pending, to: :processing
      end

      event :finish, after: :instrument_finish do
        transitions from: :processing, to: :finished
      end

      event :fail, after: :instrument_fail do
        transitions from: :processing, to: :errored
      end

      event :refund, after: :instrument_refund do
        transitions from: :finished, to: :refunded
      end
    end


    private

    def charge_card
      Payola::ChargeCard.call(self)
    end

    def instrument_finish
      Payola.instrument('payola.sale.finished', self)
    end

    def instrument_fail
      Payola.instrument('payola.sale.failed', self)
    end

    def instrument_refund
      Payola.instrument('payola.sale.refunded', self)
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

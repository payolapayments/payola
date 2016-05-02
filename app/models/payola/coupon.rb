module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
    validates_presence_of :duration

    validates_numericality_of :amount_off, allow_blank: true
    validates_numericality_of :percent_off, allow_blank: true, greater_than: 0, less_than_or_equal_to: 100

    validate :amount_xor_percent

  private

    def amount_xor_percent
      unless amount_off.blank? ^ percent_off.blank?
        errors.add(:base, "Specify an amount off or a percent off, not both")
      end
    end

    before_create  :create_stripe_coupon,  if: -> { Payola.create_stripe_coupons }
    before_destroy :destroy_stripe_coupon, if: -> { Payola.create_stripe_coupons }

    def create_stripe_coupon
      Payola::CreateCoupon.call(self)
    end

    def destroy_stripe_coupon
      Payola::DestroyCoupon.call(self.code)
    end
  end
end

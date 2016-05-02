module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
    validates_presence_of :duration
    validates :percent_off, numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 }

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

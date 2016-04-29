module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
    validates_presence_of :duration

    before_create  :create_stripe_coupon,  if: -> { Payola.create_stripe_coupons }

    def create_stripe_coupon
      Payola::CreateCoupon.call(self)
    end
  end
end

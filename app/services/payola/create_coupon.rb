module Payola
  class CreateCoupon
    def self.call(coupon)
      if coupon.save!
        begin
          return Stripe::Coupon.retrieve(coupon.code)
        rescue Stripe::InvalidRequestError
          # fall through
        end

        Stripe::Coupon.create({
          id:                 coupon.code,
          amount_off:         coupon.amount_off,
          percent_off:        coupon.percent_off,
          duration:           coupon.duration,
          duration_in_months: coupon.duration_in_months
        })
      end
    end
  end
end

module Payola
  class CreateStripeCoupon
    def self.call(coupon)
      secret_key = Payola.secret_key_for_sale(coupon)
      params = {
        :id => coupon.stripe_id,
        :currency => coupon.respond_to?(:currency) ? coupon.currency : Payola.default_currency,
        :duration => coupon.duration,
        :duration_in_months => coupon.duration_in_months,
        :max_redemptions => coupon.max_redemptions,
        :redeem_by => coupon.redeem_by
      }
      if coupon.amount_off.present?
        params[:amount_off] = coupon.amount_off
      else
        params[:percent_off] = coupon.percent_off
      end
      Stripe::Coupon.create(params,secret_key)
    end
  end
end

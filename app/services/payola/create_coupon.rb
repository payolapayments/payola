module Payola
  class CreateCoupon
    def self.call(params)
      secret_key = Payola.secret_key

      code               = params[:code]
      duration           = params[:duration]
      max_redemptions    = params[:max_redemptions]
      redeem_by          = params[:redeem_by]
      currency           = params[:currency].present?  ? params[:currency] : Payola.default_currency

      if duration == 'repeating'
        duration_in_months = params[:duration_in_months]
      else
        duration_in_months = nil
      end

      begin
        return Stripe::Coupon.retrieve(code, secret_key)
      rescue Stripe::InvalidRequestError
        # fall through
      end

      Stripe::Coupon.create({
        id: code,
        duration: duration,
        duration_in_months: duration_in_months,
        max_redemptions: max_redemptions,
        amount_off:  params[:amount_off].presence,
        percent_off: params[:percent_off].presence,
        currency:  currency,
        redeem_by: redeem_by,
        metadata:  params[:metadata].presence
      }, secret_key)
    end
  end
end
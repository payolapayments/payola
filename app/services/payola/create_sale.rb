module Payola
  class CreateSale
    def self.call(params)
      product   = params[:product]
      affiliate = params[:affiliate]
      coupon    = params[:coupon]

      Payola::Sale.new do |s|
        s.product = product
        s.email = params[:stripeEmail]
        s.stripe_token = params[:stripeToken]
        s.affiliate_id = affiliate.try(:id)
        s.currency = product.respond_to?(:currency) ? product.currency : Payola.default_currency
        s.signed_custom_fields = params[:signed_custom_fields]
        s.stripe_customer_id = params[:stripe_customer_id]

        if coupon
          s.coupon = coupon
          s.amount = product.price * (1 - s.coupon.percent_off / 100.0)
        else
          s.amount = product.price
        end
      end
    end
  end
end

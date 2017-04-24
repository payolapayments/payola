module Payola
  class CreateSale
    def self.call(params)
      product   = params[:product]
      affiliate = params[:affiliate]
      coupon    = params[:coupon]

      if params[:stripe_customer_id].present?
        customer = Stripe::Customer.retrieve(params[:stripe_customer_id], Payola.secret_key)
        email = customer.email
        token = customer.default_source
      else
        email = params[:stripeEmail]
        token = params[:stripeToken]
      end

      Payola::Sale.new do |s|
        s.product = product
        s.email = email
        s.stripe_token = token
        s.affiliate_id = affiliate.try(:id)
        if params[:currency].present?
          s.currency = params[:currency]
        else
          s.currency = product.respond_to?(:currency) ? product.currency : Payola.default_currency
        end
        s.signed_custom_fields = params[:signed_custom_fields]
        s.stripe_customer_id = customer.id if customer

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

module Payola
  class DestroyCoupon
    def self.call(code)
      secret_key = Payola.secret_key
      Stripe::Coupon.retrieve(code, secret_key).delete
    end
  end
end

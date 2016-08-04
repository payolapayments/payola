require 'spec_helper'

module Payola
  describe DestroyCoupon do
  
    before do
      Payola.secret_key = 'sk_test_12345'

      @coupon = Stripe::Coupon.create({
        percent_off: 25,
        duration: 'repeating',
        duration_in_months: 3,
        id: '25OFF'
      })
    end

    describe "#call" do
      it "destroys the coupon" do
        expect{ Payola::DestroyCoupon.call(@coupon.id) }.to_not raise_error
        expect{ Stripe::Coupon.retrieve(@coupon.id, Payola.secret_key) }.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe CreateStripeCoupon do
    before do
      @coupon = create(:app_coupon) # this calls CreateStripeCoupon.call in a before_save hook
    end

    describe "#call" do
      it "should create a coupon at Stripe" do
        sc = Stripe::Coupon.retrieve(@coupon.stripe_id)
        expect(sc).not_to be_nil
        expect(sc.amount_off).to eq 1
        expect(sc.currency).to eq 'usa'
        expect(sc.duration).to eq 'forever'
        expect(sc.duration_in_months).to eq 2
        expect(sc.max_redemptions).to eq 1
        expect(sc.redeem_by).to eq '2014-11-11 22:16:51'
      end
    end

  end
end

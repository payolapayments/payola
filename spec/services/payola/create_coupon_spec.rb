require 'spec_helper'

module Payola
  describe CreateCoupon do
  
    let(:coupon) { create(:payola_coupon) }

    before do
      Payola.secret_key = 'sk_test_12345'
    end

    describe "#call" do
      it "creates a coupon" do
        @coupon = CreateCoupon.call(
          percent_off: 25,
          duration: 'repeating',
          duration_in_months: 3,
          code: '25OFF'
        )

        expect(@coupon.id).to eq '25OFF'
        expect(@coupon.percent_off).to eq 25
        expect(@coupon.duration).to eq 'repeating'
        expect(@coupon.duration_in_months).to eq 3
      end     
    end
  end
end

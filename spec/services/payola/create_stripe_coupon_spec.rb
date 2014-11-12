require 'spec_helper'

module Payola
  describe CreateStripeCoupon do
    before do
      @coupon = create(:app_coupon)
    end

    describe "#call" do
      it "should create a coupon at Stripe" do
        
      end
    end

  end
end

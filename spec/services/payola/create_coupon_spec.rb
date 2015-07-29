require 'spec_helper'

module Payola
  describe CreateCoupon do
    describe "#call" do
      context "percent off" do
        let(:coupon) { build :payola_coupon, percent_off: 20 }
        let(:result) { Stripe::Coupon.retrieve(coupon.code) }

        before { Payola::CreateCoupon.call(coupon) }

        it "should create a coupon at Stripe" do
          expect(result["id"]).to                 eq(coupon.code)
          expect(result["duration"]).to           eq(coupon.duration)
          expect(result["duration_in_months"]).to eq(coupon.duration_in_months)
          expect(result["percent_off"]).to        eq(coupon.percent_off)
          expect(result["amount_off"]).to         eq(coupon.amount_off)
        end
      end

      context "amount off" do
        let(:coupon) { build :payola_coupon, percent_off: nil, amount_off: 1000 }
        let(:result) { Stripe::Coupon.retrieve(coupon.code) }

        before { Payola::CreateCoupon.call(coupon) }

        it "should create a coupon at Stripe" do
          expect(result["id"]).to                 eq(coupon.code)
          expect(result["duration"]).to           eq(coupon.duration)
          expect(result["duration_in_months"]).to eq(coupon.duration_in_months)
          expect(result["percent_off"]).to        eq(coupon.percent_off)
          expect(result["amount_off"]).to         eq(coupon.amount_off)
        end
      end

      context "exists in stripe" do
        let(:coupon) { create :payola_coupon, percent_off: nil, amount_off: 1000 }

        it "should skip creating a coupon if there is already a coupon with that code" do
          Payola::CreateCoupon.call(coupon)

          expect(Stripe::Coupon).to_not receive(:create)

          Payola::CreateCoupon.call(coupon)
        end
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe Coupon do
    describe "validations" do
      it "should validate uniqueness of coupon code" do
        c1 = create :payola_coupon, code: 'abc'
        expect(c1).to be_valid

        c2 = build :payola_coupon, code: 'abc'
        expect(c2).not_to be_valid
      end

      context "duration required" do
        it do
          c1 = build :payola_coupon, duration: nil
          expect(c1).not_to be_valid
        end
      end

      context "duration inclusion" do
        it "should allow 'once'" do
          c1 = build :payola_coupon, duration: 'once'
          expect(c1).to be_valid
        end

        it "should allow 'repeating'" do
          c1 = build :payola_coupon, duration: 'repeating', duration_in_months: 2
          expect(c1).to be_valid
        end

        it "should allow 'forever'" do
          c1 = build :payola_coupon, duration: 'forever'
          expect(c1).to be_valid
        end

        it "should not allow 'something' else" do
          c1 = build :payola_coupon, duration: 'something'
          expect(c1).not_to be_valid
        end
      end

      context "duration_in_months required" do
        it "should require duration_in_months if duration is 'repeating'" do
          c1 = build :payola_coupon, duration: 'repeating'
          expect(c1).not_to be_valid
        end

        it "should not require duration_in_months if duration is not 'repeating'" do
          c1 = build :payola_coupon, duration: 'once'
          expect(c1).to be_valid
        end
      end
    end

    describe "active" do
      it "should allow active flag" do
        c1 = build :payola_coupon, active: false
        expect(c1.active?).to be_falsey
      end

      it "should be true by default" do
        c1 = build :payola_coupon
        expect(c1.active?).to be_truthy
      end
    end

    describe "amount_off" do
      it "should allow amount_off" do
        c1 = build :payola_coupon, amount_off: 999
        expect(c1.amount_off).not_to be_nil
      end
    end

    describe "duration" do
      it "should allow duration" do
        c1 = build :payola_coupon, duration: 3
        expect(c1.duration).not_to be_nil
      end
    end
  end
end

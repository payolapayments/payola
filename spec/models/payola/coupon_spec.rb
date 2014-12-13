require 'spec_helper'

module Payola
  describe Coupon do
    describe "validations" do
      it "should validate uniqueness of coupon code" do
        c1 = Coupon.create(code: 'abc')
        expect(c1.valid?).to be_truthy

        c2 = Coupon.new(code: 'abc')
        expect(c2.valid?).to be_falsey
      end
    end

    describe "active" do
      it "should allow active flag" do
        c1 = Coupon.create(code: 'abc', active: false)
        expect(c1.active?).to be_falsey
      end

      it "should be true by default" do
        c1 = Coupon.create(code: 'abc')
        expect(c1.active?).to be_truthy
      end
    end
  end
end

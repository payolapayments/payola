require 'spec_helper'

module Payola
  describe Coupon do

    before { Payola.create_stripe_coupons = false }

    describe "validations" do
      it "should validate uniqueness of coupon code" do
        c1 = Coupon.create(code: 'abc')
        expect(c1.valid?).to be_truthy

        c2 = Coupon.new(code: 'abc')
        expect(c2.valid?).to be_falsey
      end

      it "validates percent_off is between 1 and 100" do
        c1 = create(:payola_coupon, percent_off: 60)
        expect(c1.valid?).to be_truthy

        c2 = build(:payola_coupon, percent_off: 0)
        expect(c2.valid?).to be_falsey

        c3 = build(:payola_coupon, percent_off: 101)
        expect(c3.valid?).to be_falsey
      end

      it "allows percentage off or amount off, but not both" do
        c1 = build(:payola_coupon, percent_off: 60)
        expect(c1.valid?).to be_truthy

        c2 = build(:payola_coupon, :flat_amount)
        expect(c2.valid?).to be_truthy

        c3 = build(:payola_coupon, percent_off: 60, amount_off: 20)
        expect(c3.valid?).to be_falsey
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

    context "with Payola.create_stripe_coupons set to false" do

      it "should not try to create the coupon at stripe before the model is created" do
        coupon = build(:payola_coupon)
        expect(Payola::CreateCoupon).to_not receive(:call)
        coupon.save!
      end

      it "should not try to create the coupon at stripe before the model is updated" do
        coupon = build(:payola_coupon)
        coupon.save!
        coupon.redeem_by = 1.week.from_now

        expect(Payola::CreateCoupon).to_not receive(:call)
        coupon.save!
      end
    end

    context "with Payola.create_stripe_coupons set to true" do
      before do
        Payola.create_stripe_coupons = true
        Payola.secret_key = 'sk_test_12345'
      end

      it "should create the coupon at stripe before the model is created" do
        coupon = build(:payola_coupon)
        expect(Payola::CreateCoupon).to receive(:call)
        coupon.save!
      end

      it "should not try to create the coupon at stripe before the model is updated" do
        coupon = build(:payola_coupon)
        coupon.save!
        coupon.redeem_by = 1.week.from_now

        expect(Payola::CreateCoupon).to_not receive(:call)
        coupon.save!
      end
    end
  end
end

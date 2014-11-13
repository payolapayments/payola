require 'spec_helper'

module Payola
  describe StripeCoupon do

    it "should validate" do
      coupon = build(:app_coupon)
      expect(coupon.valid?).to be true
    end

    it "should validate amount_off" do
      coupon = build(:app_coupon, amount_off: nil)
      expect(coupon.valid?).to be false
    end

    it "should validate percent_off and amount_off aren't both present" do
      coupon = build(:app_coupon, percent_off: 1, amount_off: 1)
      expect(coupon.valid?).to be false
    end

    it "should validate duration" do
      coupon = build(:app_coupon, duration: nil)
      expect(coupon.valid?).to be false
    end

    it "should validate duration" do
      coupon = build(:app_coupon, duration: 'random')
      expect(coupon.valid?).to be false
    end

    it "should validate duration_in_months" do
      coupon = build(:app_coupon, duration_in_months: nil, duration: 'repeating')
      expect(coupon.valid?).to be false
    end

    it "should validate stripe_id" do
      coupon = build(:app_coupon, stripe_id: nil)
      expect(coupon.valid?).to be false
    end

    it "should create the coupon at stripe before the model is created" do
      coupon = build(:app_coupon)
      Payola::CreateStripeCoupon.should_receive(:call)
      coupon.save!
    end

  end
end

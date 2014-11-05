require 'spec_helper'

module Payola
  describe Plan do

    it "should validate" do
      subscription_plan = build(:subscription_plan)
      expect(subscription_plan.valid?).to be true
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, amount: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, interval: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, interval_count: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, stripe_id: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, name: nil)
      expect(subscription_plan.valid?).to be false
    end


  end
end

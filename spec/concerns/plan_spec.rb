require 'spec_helper'

module Payola
  describe Plan do

    it "should validate" do
      subscription_plan = build(:subscription_plan)
      expect(subscription_plan.valid?).to be true
    end

    it "should validate amount" do
      subscription_plan = build(:subscription_plan, amount: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate interval" do
      subscription_plan = build(:subscription_plan, interval: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate stripe_id" do
      subscription_plan = build(:subscription_plan, stripe_id: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should validate name" do
      subscription_plan = build(:subscription_plan, name: nil)
      expect(subscription_plan.valid?).to be false
    end

    it "should create the plan at stripe before the model is created" do
      subscription_plan = build(:subscription_plan)
      Payola::CreatePlan.should_receive(:call)
      subscription_plan.save!
    end

    it "should not try to create the plan at stripe before the model is updated" do
      subscription_plan = build(:subscription_plan)
      subscription_plan.save!
      subscription_plan.name = "new name"

      Payola::CreatePlan.should_not_receive(:call)
      subscription_plan.save!
    end

  end
end

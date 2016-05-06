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

    context "with an associated subscription" do
      let :subscription do
        create(:subscription, plan: create(:subscription_plan))
      end

      it "should fail when attempting to destroy it" do
        expect {
          subscription.plan.destroy
        }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end

    context "with Payola.create_stripe_plans set to true" do
      before { Payola.create_stripe_plans = true }

      it "should create the plan at stripe before the model is created" do
        subscription_plan = build(:subscription_plan)
        expect(Payola::CreatePlan).to receive(:call)
        subscription_plan.save!
      end

      it "should not try to create the plan at stripe before the model is updated" do
        subscription_plan = build(:subscription_plan)
        subscription_plan.save!
        subscription_plan.name = "new name"

        expect(Payola::CreatePlan).to_not receive(:call)
        subscription_plan.save!
      end
    end

    context "with Payola.create_stripe_plans set to false" do
      before(:example) { Payola.create_stripe_plans = false }
      after(:example) { Payola.create_stripe_plans = true }

      it "should not try to create the plan at stripe before the model is created" do
        subscription_plan = build(:subscription_plan)
        expect(Payola::CreatePlan).to_not receive(:call)
        subscription_plan.save!
      end

      it "should not try to create the plan at stripe before the model is updated" do
        subscription_plan = build(:subscription_plan)
        subscription_plan.save!
        subscription_plan.name = "new name"

        expect(Payola::CreatePlan).to_not receive(:call)
        subscription_plan.save!
      end
    end
  end
end

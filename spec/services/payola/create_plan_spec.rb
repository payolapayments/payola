require 'spec_helper'

module Payola
  describe CreatePlan do
    before do
      @subscription_plan = create(:subscription_plan)
    end

    describe "#call" do
      it "should create a plan at Stripe" do
        plan = CreatePlan.call(
          plan_class: @subscription_plan.class,
          plan_id: @subscription_plan.id
        )
        expect(plan.name).to eq @subscription_plan.name
        expect(plan.amount).to eq @subscription_plan.amount
        expect(plan.id).to eq @subscription_plan.stripe_id
        expect(plan.interval).to eq @subscription_plan.interval
        expect(plan.interval_count).to eq @subscription_plan.interval_count
        expect(plan.currency).to eq 'usd'
        expect(plan.trial_period_days).to eq @subscription_plan.trial_period_days
      end
    end

  end
end

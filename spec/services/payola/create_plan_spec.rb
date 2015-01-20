require 'spec_helper'

module Payola
  describe CreatePlan do
    before do
      @subscription_plan = create(:subscription_plan)
    end

    describe "#call" do
      it "should create a plan at Stripe" do
        plan = Stripe::Plan.retrieve(@subscription_plan.stripe_id)

        expect(plan.name).to eq @subscription_plan.name
        expect(plan.amount).to eq @subscription_plan.amount
        expect(plan.id).to eq @subscription_plan.stripe_id
        expect(plan.interval).to eq @subscription_plan.interval
        expect(plan.interval_count).to eq @subscription_plan.interval_count
        expect(plan.currency).to eq 'usd'
        expect(plan.trial_period_days).to eq @subscription_plan.trial_period_days
      end

      it "should default interval_count" do
        our_plan = create(:subscription_plan_without_interval_count)

        expect(our_plan.respond_to?(:interval_count)).to eq false

        plan = Stripe::Plan.retrieve(our_plan.stripe_id)
        expect(plan.interval_count).to be_nil
      end

      it "should skip creating a plan if there is already a plan with that stripe id" do
        expect(Stripe::Plan).to_not receive(:create)

        Payola::CreatePlan.call(@subscription_plan)
      end
    end

  end
end

require 'spec_helper'

module Payola
  describe ChangeSubscriptionPlan do
    let(:stripe_helper) { StripeMock.create_test_helper }

    describe "#call" do
      before do
        @plan1 = create(:subscription_plan)
        @plan2 = create(:subscription_plan)

        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, plan: @plan1, stripe_token: token)
        StartSubscription.call(@subscription)
        Payola::ChangeSubscriptionPlan.call(@subscription, @plan2)
      end

      it "should change the plan on the stripe subscription" do
        customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        sub = customer.subscriptions.retrieve(@subscription.stripe_id)

        expect(sub.plan.id).to eq @plan2.stripe_id
      end

      it "should change the plan on the payola subscription" do
        expect(@subscription.reload.plan).to eq @plan2
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe ChangeSubscriptionQuantity do
    let(:stripe_helper) { StripeMock.create_test_helper }

    describe "#call" do
      before do
        @plan = create(:subscription_plan)

        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, quantity: 1, stripe_token: token)
        StartSubscription.call(@subscription)
        Payola::ChangeSubscriptionQuantity.call(@subscription, 2)
      end

      it "should change the quantity on the stripe subscription" do
        customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        sub = customer.subscriptions.retrieve(@subscription.stripe_id)

        expect(sub.quantity).to eq 2
      end

      it "should change the quantity on the payola subscription" do
        expect(@subscription.reload.quantity).to eq 2
      end
    end
  end
end

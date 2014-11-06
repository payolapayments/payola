require 'spec_helper'

module Payola
  describe StartSubscription do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:token){ StripeMock.generate_card_token({}) }
    describe "#call" do
      it "should create a customer" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
        StartSubscription.call(subscription)
        expect(subscription.reload.stripe_customer_id).to_not be_nil
      end
      it "should capture credit card info" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
        StartSubscription.call(subscription)
        expect(subscription.reload.stripe_id).to_not be_nil
        expect(subscription.reload.card_last4).to_not be_nil
        expect(subscription.reload.card_expiration).to_not be_nil
        expect(subscription.reload.card_type).to_not be_nil
      end
      #describe "on error" do
        #it "should update the error attribute" do
          #StripeMock.prepare_card_error(:card_declined)
          #plan = create(:subscription_plan)
          #subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
          #StartSubscription.call(subscription)
          #expect(subscription.reload.error).to_not be_nil
          #expect(subscription.errored?).to be true
        #end
      #end
    end
  end
end




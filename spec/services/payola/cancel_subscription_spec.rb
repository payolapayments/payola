require 'spec_helper'

module Payola
  describe CancelSubscription do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:token){ StripeMock.generate_card_token({}) }
    describe "#call" do
      before :each do
        plan = create(:subscription_plan)
        @subscription = create(:subscription, plan: plan, stripe_token: token)
        @subscription.process!
        @subscription.cancel!
      end
      it "should cancel a subscription" do
        CancelSubscription.call(@subscription)
        expect(@subscription.reload.state).to eq 'canceled'
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




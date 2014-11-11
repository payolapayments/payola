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
    end
  end
end




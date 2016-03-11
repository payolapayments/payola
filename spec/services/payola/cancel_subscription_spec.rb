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
      end

      context "when at_period_end is true" do
        it "leaves the subscription in the active state" do
          CancelSubscription.call(@subscription, at_period_end: true)
          expect(@subscription.reload.state).to eq 'active'
        end

        it "sets subscription.cancel_at_period_end to true" do
          CancelSubscription.call(@subscription, at_period_end: true)
          expect(@subscription.reload.cancel_at_period_end).to be true
        end
      end

      context "when at_period_end is not true" do
        it "cancels the subscription immediately" do
          CancelSubscription.call(@subscription)
          expect(@subscription.reload.state).to eq 'canceled'
        end
      end

      it "should not change the state if an error occurs" do
        custom_error = StandardError.new("Customer not found")
        StripeMock.prepare_error(custom_error, :get_customer)
        expect { CancelSubscription.call(@subscription) }.to raise_error("Customer not found")
        
        expect(@subscription.reload.state).to eq 'active'
      end
    end
  end
end




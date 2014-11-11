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
      it "should cancel a subscription" do
        CancelSubscription.call(@subscription)
        expect(@subscription.reload.state).to eq 'canceled'
      end
      it "should not change the state if an error occurs" do
        custom_error = StandardError.new("Customer not found")
        StripeMock.prepare_error(custom_error, :get_customer)
        expect { CancelSubscription.call(@subscription) }.to raise_error
        
        expect(@subscription.reload.state).to eq 'active'
      end
    end
  end
end




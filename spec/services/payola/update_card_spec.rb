require 'spec_helper'

module Payola
  describe UpdateCard do
    let(:stripe_helper) { StripeMock.create_test_helper }

    describe "#call" do
      before do
        @plan = create(:subscription_plan)

        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, plan: @plan, stripe_token: token, state: 'processing')
        StartSubscription.call(@subscription)
        expect(@subscription.error).to be_nil
        expect(@subscription.active?).to be_truthy
        token2 = StripeMock.generate_card_token({last4: '2233', exp_year: '2021', exp_month: '11', brand: 'JCB'})
        Payola::UpdateCard.call(@subscription, token2)
      end

      it "should change the card" do
        @subscription.reload
        expect(@subscription.card_last4).to eq '2233'
        expect(@subscription.card_expiration).to eq Date.new(2021,11,1)
        expect(@subscription.card_type).to eq 'JCB'
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe Subscription do

    describe "validations" do
      it "should validate" do
        subscription = build(:subscription)
        expect(subscription.valid?).to be true
      end

      it "should validate plan" do
        subscription = build(:subscription, plan: nil)
        expect(subscription.valid?).to be false
      end

      it "should validate lack of email" do
        subscription = build(:subscription, email: nil)
        expect(subscription.valid?).to be false
      end

      it "should validate stripe_token" do
        subscription = build(:subscription, stripe_token: nil)
        expect(subscription.valid?).to be false
      end

    end

    describe "#sync_with!" do
      it "should sync timestamps" do
        plan = create(:subscription_plan)
        subscription = build(:subscription, plan: plan)
        stripe_sub = Stripe::Customer.create.subscriptions.create(plan: plan.stripe_id, source: StripeMock.generate_card_token(last4: '1234', exp_year: Time.now.year + 1))
        old_start = subscription.current_period_start
        old_end = subscription.current_period_end
        trial_start = subscription.trial_start
        trial_end = subscription.trial_end

        now = Time.now.to_i
        expect(stripe_sub).to receive(:canceled_at).and_return(now).at_least(1)

        subscription.sync_with!(stripe_sub)

        subscription.reload

        expect(subscription.current_period_start).to eq Time.at(stripe_sub.current_period_start)
        expect(subscription.current_period_start).to_not eq old_start
        expect(subscription.current_period_end).to eq Time.at(stripe_sub.current_period_end)
        expect(subscription.current_period_end).to_not eq old_end
        expect(subscription.canceled_at).to eq Time.at(now)
      end

      it "should sync non-timestamp fields" do
        plan = create(:subscription_plan)
        subscription = build(:subscription, plan: plan)
        stripe_sub = Stripe::Customer.create.subscriptions.create(plan: plan.stripe_id, source: StripeMock.generate_card_token(last4: '1234', exp_year: Time.now.year + 1))

        expect(stripe_sub).to receive(:quantity).and_return(10).at_least(1)
        expect(stripe_sub).to receive(:cancel_at_period_end).and_return(true).at_least(1)

        subscription.sync_with!(stripe_sub)

        subscription.reload

        expect(subscription.quantity).to eq 10
        expect(subscription.stripe_status).to eq 'active'
        expect(subscription.cancel_at_period_end).to eq true
      end
    end
  end
end

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
        sale = build(:sale, email: nil)
        expect(sale.valid?).to be false
      end

      it "should validate stripe_token" do
        sale = build(:sale, stripe_token: nil)
        expect(sale.valid?).to be false
      end

    end

    describe "#sync_with!" do
      it "should sync timestamps" do
        plan = create(:subscription_plan)
        subscription = build(:subscription, plan: plan)
        stripe_sub = Stripe::Customer.create.subscriptions.create(plan: plan.stripe_id, card: StripeMock.generate_card_token(last4: '1234', exp_year: Time.now.year + 1))
        old_start = subscription.current_period_start
        old_end = subscription.current_period_end
        trial_start = subscription.trial_start
        trial_end = subscription.trial_end

        subscription.sync_with!(stripe_sub)

        subscription.reload

        expect(subscription.current_period_start).to eq Time.at(stripe_sub.current_period_start)
        expect(subscription.current_period_start).to_not eq old_start
        expect(subscription.current_period_end).to eq Time.at(stripe_sub.current_period_end)
        expect(subscription.current_period_end).to_not eq old_end
      end
    end
  end
end

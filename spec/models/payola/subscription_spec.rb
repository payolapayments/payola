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

      it "should not validate nil stripe_token on paid plan" do
        plan = create(:subscription_plan)
        subscription = build(:subscription, stripe_token: nil, plan: plan)
        expect(subscription.valid?).to be false
      end

      it "should validate stripe_token" do
        subscription = build(:subscription, stripe_token: nil)
        expect(subscription.valid?).to be true
      end

      it "should validate nil stripe_token when the subscription owner is present" do
        plan = create(:subscription_plan)
        plan.amount = 0
        subscription = build(:subscription, stripe_token: nil, owner: build(:sale))
        expect(subscription.valid?).to be true
      end

      it "should validate nil stripe_token when the stripe_customer_id is specified" do
        plan = create(:subscription_plan)
        plan.amount = 0
        subscription = build(:subscription, stripe_token: nil, stripe_customer_id: "cus_123456")
        expect(subscription.valid?).to be true
      end

      it "should validate nil stripe_token on free plan" do
        plan = create(:subscription_plan)
        plan.amount = 0
        subscription = build(:subscription, stripe_token: nil, plan: plan)
        expect(subscription.valid?).to be true
      end

      it "should validate nil stripe_token on plan with trial" do
        plan = create(:subscription_plan)
        plan.trial_period_days = 30
        subscription = build(:subscription, stripe_token: nil, plan: plan)
        expect(subscription.valid?).to be true
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
        plan = create(:subscription_plan, amount: 200)
        subscription = build(:subscription, plan: plan, amount: 50)
        stripe_sub = Stripe::Customer.create.subscriptions.create(plan: plan.stripe_id, source: StripeMock.generate_card_token(last4: '1234', exp_year: Time.now.year + 1))
        coupon = create(:payola_coupon)
        allow(stripe_sub).to receive_message_chain(:discount, :coupon, :id).and_return(coupon.code)

        expect(stripe_sub).to receive(:quantity).and_return(10).at_least(1)
        expect(stripe_sub).to receive(:cancel_at_period_end).and_return(true).at_least(1)

        subscription.sync_with!(stripe_sub)

        subscription.reload

        expect(subscription.quantity).to eq 10
        expect(subscription.amount).to eq 200
        expect(subscription.stripe_status).to eq 'active'
        expect(subscription.cancel_at_period_end).to eq true
        expect(subscription.coupon).to eq coupon.code
      end
    end
  end
end

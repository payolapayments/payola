require 'spec_helper'

module Payola
  describe ChangeSubscriptionPlan do
    let(:stripe_helper) { StripeMock.create_test_helper }

    describe "#call" do
      before do
        @plan1 = create(:subscription_plan)
        @plan2 = create(:subscription_plan)

        @token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, plan: @plan1, stripe_token: @token)
        StartSubscription.call(@subscription)
      end

      context "default" do
        before { Payola::ChangeSubscriptionPlan.call(@subscription, @plan2) }

        it "should change the plan on the stripe subscription" do
          customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
          sub = customer.subscriptions.retrieve(@subscription.stripe_id)

          expect(sub.plan.id).to eq @plan2.stripe_id
        end

        it "should change the plan on the payola subscription" do
          expect(@subscription.reload.plan).to eq @plan2
        end
      end

      context "trial_end" do
        before do
          @sub = Stripe::Subscription.new

          allow(@sub).to receive(:save).and_return(true) # trial_end value is wiped when save is called
          allow(ChangeSubscriptionPlan).to receive(:retrieve_subscription_for_customer).and_return(@sub)
        end

        context "not set" do
          before do
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2)
          end

          it "should not have trial_end set" do
            expect(@sub.try(:trial_end)).to be_nil
          end
        end

        context "set" do
          before do
            @quantity = 1
            @coupon = nil
            @trial_end = "now"
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2, @quantity, @coupon, @trial_end)
          end

          it "should have the trial_end" do
            expect(@sub.trial_end).to eq(@trial_end)
          end
        end
      end

      context "coupon" do
        before do
          @sub = Stripe::Subscription.new

          allow(@sub).to receive(:save).and_return(true) # coupon value is wiped when save is called
          allow(ChangeSubscriptionPlan).to receive(:retrieve_subscription_for_customer).and_return(@sub)
        end

        context "not set" do
          before do
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2)
          end

          it "should not have the coupon" do
            expect(@sub.try(:coupon)).to be_nil
          end
        end

        context "set" do
          before do
            @coupon = build :payola_coupon
            @quantity = 1
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2, @quantity, @coupon)
          end

          it "should have the coupon" do
            expect(@sub.coupon.code).to eq(@coupon.code)
          end
        end
      end

      context "subscription.cancel_at_period_end" do
        context "not set" do
          before do
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2)
          end

          it "should not change" do
            expect(@subscription.cancel_at_period_end).to be false
          end
        end

        context "set" do
          before do
            @subscription = create(:subscription, plan: @plan1, stripe_token: @token, cancel_at_period_end: true)
            StartSubscription.call(@subscription)
            Payola::ChangeSubscriptionPlan.call(@subscription, @plan2)
          end

          it "should be reset to false" do
            expect(@subscription.cancel_at_period_end).to be false
          end
        end
      end
    end

    describe ".should_prorate?" do
      let(:subscription)  { build :subscription }
      let(:plan)          { build :subscription_plan }
      let(:coupon_code)   { nil }
      let(:prorate)       { ChangeSubscriptionPlan.should_prorate?(subscription, plan, coupon_code) }

      context "plan doesn't respond to should_prorate?" do
        it { expect(prorate).to eq(true) }
      end

      context "plan.should_prorate? is false" do
        before { allow(plan).to receive(:should_prorate?).and_return(false) }

        it { expect(prorate).to eq(false) }
      end

      context "plan.should_prorate? is true" do
        before { allow(plan).to receive(:should_prorate?).and_return(true) }

        it { expect(prorate).to eq(true) }
      end

      context "plan.should_prorate? is true, coupon overrides" do
        let(:coupon_code) { build :payola_coupon }
        before { allow(plan).to receive(:should_prorate?).and_return(true) }

        it { expect(prorate).to eq(false) }
      end
    end
  end
end

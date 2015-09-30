require 'spec_helper'

module Payola
  describe CreateSubscription do
    before do
      @plan = create(:subscription_plan)
      Payola.background_worker = Payola::FakeWorker
    end

    describe "#call" do
      it "should create a subscription and queue the job" do
        expect(Payola).to receive(:queue!)

        subscription = CreateSubscription.call(
          stripeEmail: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          plan: @plan,
          tax_percent: 20
        )

        expect(subscription.email).to eq 'pete@bugsplat.info'
        expect(subscription.stripe_token).to eq 'test_tok'
        expect(subscription.plan_id).to eq @plan.id
        expect(subscription.plan).to eq @plan
        expect(subscription.plan_type).to eq 'SubscriptionPlan'
        expect(subscription.currency).to eq 'usd'
        expect(subscription.tax_percent).to eq 20
      end
            
      it "should include the affiliate if given" do
        affiliate = create(:payola_affiliate)
        subscription = CreateSubscription.call(
          email: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          plan: @plan,
          affiliate: affiliate
        )

        expect(subscription.affiliate).to eq affiliate
      end
    end
  end
end

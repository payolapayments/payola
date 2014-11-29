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

        sale = CreateSubscription.call(
          stripeEmail: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          plan: @plan
        )

        expect(sale.email).to eq 'pete@bugsplat.info'
        expect(sale.stripe_token).to eq 'test_tok'
        expect(sale.plan_id).to eq @plan.id
        expect(sale.plan).to eq @plan
        expect(sale.plan_type).to eq 'SubscriptionPlan'
        expect(sale.currency).to eq 'usd'
      end
            
      it "should include the affiliate if given" do
        affiliate = create(:payola_affiliate)
        sale = CreateSubscription.call(
          email: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          plan: @plan,
          affiliate: affiliate
        )

        expect(sale.affiliate).to eq affiliate
      end
    end
  end
end

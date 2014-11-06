require 'spec_helper'

module Payola
  describe CreateSubscription do
    before do
      @plan = create(:subscription_plan)
    end

    describe "#call" do
      it "should create a sale" do
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
            
      #it "should include the affiliate if given" do
        #affiliate = create(:payola_affiliate)
        #sale = CreateSubscription.call(
          #email: 'pete@bugsplat.info',
          #stripeToken: 'test_tok',
          #plan: @plan,
          #affiliate: affiliate
        #)

        #expect(sale.affiliate).to eq affiliate
      #end

      #describe "with coupon" do
        #it "should include the coupon" do
          #coupon = create(:payola_coupon)

          #sale = CreateSubscription.call(
            #email: 'pete@bugsplat.info',
            #stripeToken: 'test_tok',
            #product: @plan,
            #coupon: coupon
          #)

          #expect(sale.coupon).to eq coupon
        #end
        #it "should set the price correctly" do
          #coupon = create(:payola_coupon)

          #sale = CreateSubscription.call(
            #email: 'pete@bugsplat.info',
            #stripeToken: 'test_tok',
            #product: @plan,
            #coupon: coupon
          #)

          #expect(sale.amount).to eq 99
        #end
      #end
    end
  end
end

require 'spec_helper'

module Payola
  describe StartSubscription do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:token){ StripeMock.generate_card_token({}) }
    let(:user){ User.create }

    describe "#call" do
      it "should create a customer" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
        StartSubscription.call(subscription)
        expect(subscription.reload.stripe_customer_id).to_not be_nil
      end
      it "should capture credit card info" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
        StartSubscription.call(subscription)
        expect(subscription.reload.stripe_id).to_not be_nil
        expect(subscription.reload.card_last4).to_not be_nil
        expect(subscription.reload.card_expiration).to_not be_nil
        expect(subscription.reload.card_type).to_not be_nil
      end
      describe "on error" do
        it "should update the error attribute" do
          StripeMock.prepare_card_error(:card_declined, :new_customer)
          plan = create(:subscription_plan)
          subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token)
          StartSubscription.call(subscription)
          expect(subscription.reload.error).to_not be_nil
          expect(subscription.errored?).to be true
        end
      end

      it "should re-use an existing customer" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token, owner: user)
        StartSubscription.call(subscription)
        CancelSubscription.call(subscription)

        subscription2 = create(:subscription, state: 'processing', plan: plan, owner: user)
        StartSubscription.call(subscription2)
        expect(subscription2.reload.stripe_customer_id).to_not be_nil
        expect(subscription2.reload.stripe_customer_id).to eq subscription.reload.stripe_customer_id
      end

      it "should not re-use an existing customer that has been deleted" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token, owner: user)
        StartSubscription.call(subscription)
        deleted_customer_id = subscription.reload.stripe_customer_id
        Stripe::Customer.retrieve(deleted_customer_id).delete

        subscription2 = create(:subscription, state: 'processing', plan: plan, owner: user, stripe_customer_id: 'MyString')
        StartSubscription.call(subscription2)
        expect(subscription2.reload.stripe_customer_id).to_not be_nil
        expect(subscription2.reload.stripe_customer_id).to_not eq deleted_customer_id
      end

      it "should create an invoice item with a setup fee" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token, owner: user, setup_fee: 100)
        StartSubscription.call(subscription)

        ii = Stripe::InvoiceItem.all(customer: subscription.stripe_customer_id).first
        expect(ii).to_not be_nil
        expect(ii.amount).to eq 100
        expect(ii.description).to eq "Setup Fee"
      end

      it "should allow the plan to override the setup fee description" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, state: 'processing', plan: plan, stripe_token: token, owner: user, setup_fee: 100)

        expect(plan).to receive(:setup_fee_description).with(subscription).and_return('Random Mystery Fee')
        StartSubscription.call(subscription)

        ii = Stripe::InvoiceItem.all(customer: subscription.stripe_customer_id).first
        expect(ii).to_not be_nil
        expect(ii.amount).to eq 100
        expect(ii.description).to eq 'Random Mystery Fee'
      end
    end
  end
end

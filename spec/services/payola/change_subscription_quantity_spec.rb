require 'spec_helper'

module Payola
  describe ChangeSubscriptionQuantity do
    let(:stripe_helper) { StripeMock.create_test_helper }

    describe "#call" do
      let(:original_quantity) { 1 }
      let(:new_quantity) { original_quantity + 1 }

      before(:each) do
        @plan = create(:subscription_plan)
        expect(@plan.errors).to be_blank

        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, quantity: original_quantity, stripe_token: token, plan: @plan, state: 'processing')
        StartSubscription.call(@subscription)
        expect(@subscription.error).to be_nil
        expect(@subscription.active?).to be_truthy
      end

      it "should not produce any subscription errors" do
        subscription = Payola::ChangeSubscriptionQuantity.call(@subscription, new_quantity)

        expect(subscription.errors).to be_blank
      end

      it "should change the quantity on the stripe subscription" do
        subscription = Payola::ChangeSubscriptionQuantity.call(@subscription, new_quantity)

        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
        sub = customer.subscriptions.retrieve(subscription.stripe_id)
        expect(sub.quantity).to eq new_quantity
      end

      it "should change the quantity on the payola subscription" do
        subscription = Payola::ChangeSubscriptionQuantity.call(@subscription, new_quantity)

        expect(subscription.reload.quantity).to eq new_quantity
      end

      it "should notify quantity has changed" do
        expect(@subscription).to receive(:instrument_quantity_changed).with(original_quantity)

        Payola::ChangeSubscriptionQuantity.call(@subscription, new_quantity)
      end
    end
  end
end

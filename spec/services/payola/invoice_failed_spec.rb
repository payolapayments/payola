require 'spec_helper'

module Payola
  describe InvoiceFailed do
    let(:stripe_helper) { StripeMock.create_test_helper }
    it "should create a failed sale" do
      plan = create(:subscription_plan)

      customer = Stripe::Customer.create(
        email: 'foo',
        source: stripe_helper.generate_card_token,
        plan: plan.stripe_id
      )

      sub = create(:subscription, plan: plan, stripe_customer_id: customer.id, stripe_id: customer.subscriptions.first.id)

      charge = Stripe::Charge.create(amount: 100, currency: 'usd', failure_message: 'Failed! OMG!', customer: customer.id)
      expect(Stripe::BalanceTransaction).to receive(:retrieve).and_return(OpenStruct.new( amount: 100, fee: 3.29, currency: 'usd' ))
      event = StripeMock.mock_webhook_event('invoice.payment_failed', subscription: sub.stripe_id, charge: charge.id)

      count = Payola::Sale.count
      sale = Payola::InvoiceFailed.call(event)

      expect(Payola::Sale.count).to eq count + 1

      expect(sale.errored?).to be true
      expect(sale.error).to eq 'Failed! OMG!'
    end
  end
end

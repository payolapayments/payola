require 'spec_helper'

module Payola
  describe InvoiceFailed do
    it "should create a failed sale" do
      plan = create(:subscription_plan)
      sub = create(:subscription, plan: plan)
      charge = Stripe::Charge.create(failure_message: 'Failed! OMG!')
      event = StripeMock.mock_webhook_event('invoice.payment_failed', subscription: sub.stripe_id, charge: charge.id)

      count = Payola::Sale.count
      sale = Payola::InvoiceFailed.call(event)

      expect(Payola::Sale.count).to eq count + 1

      expect(sale.errored?).to be true
      expect(sale.error).to eq 'Failed! OMG!'
    end
  end
end

require 'spec_helper'

module Payola
  describe InvoicePaid do
    it "should do nothing if the invoice has no charge" do
      # create a Payola::Subscription
      plan = create(:subscription_plan)
      sub = create(:subscription, plan: plan)

      event = StripeMock.mock_webhook_event('invoice.payment_succeeded', subscription: sub.stripe_id, charge: nil)

      count = Payola::Sale.count

      Payola::InvoicePaid.call(event)

      expect(Payola::Sale.count).to eq count
    end

    it "should create a sale" do
      plan = create(:subscription_plan)
      sub = create(:subscription, plan: plan)
      charge = Stripe::Charge.create
      event = StripeMock.mock_webhook_event('invoice.payment_succeeded', subscription: sub.stripe_id, charge: charge.id)

      count = Payola::Sale.count

      sale = Payola::InvoicePaid.call(event)

      expect(Payola::Sale.count).to eq count + 1

      expect(sale.finished?).to be true
    end
  end
end

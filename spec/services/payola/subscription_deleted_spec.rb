require 'spec_helper'

module Payola
  describe SubscriptionDeleted do
    it "should cancel the subscription that was deleted" do
      sub = create(:subscription, state: 'active')
      event = StripeMock.mock_webhook_event('customer.subscription.deleted', id: sub.stripe_id)
      expect { Payola::SubscriptionDeleted.call(event) }.to change { sub.reload.state }.from('active').to('canceled')
    end
  end
end

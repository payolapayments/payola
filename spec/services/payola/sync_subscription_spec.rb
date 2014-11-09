require 'spec_helper'

module Payola
  describe SyncSubscription do
    it "should call sync_with!" do
      expect_any_instance_of(Payola::Subscription).to receive(:sync_with!)
      sub = create(:subscription)

      event = StripeMock.mock_webhook_event('customer.subscription.updated', id: sub.stripe_id)

      Payola::SyncSubscription.call(event)
    end
  end
end

module Payola
  class UpdateSubscription
    def self.call(event)
      stripe_sub = event.data.object

      sub = Payola::Subscription.find_by(stripe_id: stripe_sub.id)

      sub.sync_with!(stripe_sub)
    end
  end
end

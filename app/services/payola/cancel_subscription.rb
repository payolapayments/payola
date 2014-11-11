module Payola
  class CancelSubscription
    def self.call(subscription)
      secret_key = Payola.secret_key_for_sale(subscription)

      customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      customer.subscriptions.retrieve(subscription.stripe_id).delete
    end

  end
end


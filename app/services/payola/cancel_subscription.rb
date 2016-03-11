module Payola
  class CancelSubscription
    def self.call(subscription, options = {})
      secret_key = Payola.secret_key_for_sale(subscription)
      customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
      customer.subscriptions.retrieve(subscription.stripe_id,secret_key).delete(options,secret_key)
      
      unless options[:at_period_end] == true
        subscription.cancel!
      end
    end

  end
end


module Payola
  class ChangeSubscriptionQuantity
    def self.call(subscription, quantity)
      secret_key = Payola.secret_key_for_sale(subscription)
      old_quantity = subscription.quantity

      begin
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
        sub = customer.subscriptions.retrieve(subscription.stripe_id)
        sub.quantity = quantity
        sub.save

        subscription.quantity = quantity
        subscription.save!

        subscription.instrument_quantity_changed(old_quantity)

      rescue RuntimeError, Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end
  end
end

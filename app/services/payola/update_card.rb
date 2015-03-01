module Payola
  class UpdateCard
    def self.call(subscription, token)
      secret_key = Payola.secret_key_for_sale(subscription)
      begin
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)

        customer.source = token
        customer.save

        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
        card = customer.sources.retrieve(customer.default_source, secret_key)

        subscription.update_attributes(
          card_type: card.brand,
          card_last4: card.last4,
          card_expiration: Date.parse("#{card.exp_year}/#{card.exp_month}/1")
        )
        subscription.save!
      rescue RuntimeError, Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end
  end
end

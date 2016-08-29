module Payola
  class UpdateCard
    def self.call(subscription, token)
      secret_key = Payola.secret_key_for_sale(subscription)
      begin
        Stripe.api_key = secret_key
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)

        customer.source = token
        customer.save

        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
        card = customer.sources.retrieve(customer.default_source)

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

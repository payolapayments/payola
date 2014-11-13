module Payola
  class UpdateCard
    def self.call(subscription, token)
      begin
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)

        customer.card = token
        customer.save

        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
        card = customer.cards.retrieve(customer.default_card)

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

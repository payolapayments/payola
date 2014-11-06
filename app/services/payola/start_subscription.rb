module Payola
  class StartSubscription
    def self.call(subscription)
      subscription.save!
      secret_key = Payola.secret_key_for_sale(subscription)

      begin
        subscription.verify_charge!
        customer = Stripe::Customer.create({
          card: subscription.stripe_token,
          email: subscription.email,
          plan: subscription.plan.stripe_id
        }, secret_key)


        card = customer.cards.data.first
        subscription.update_attributes(
          stripe_id:          customer.subscriptions.data.first.id,
          stripe_customer_id: customer.id,
          card_last4:         card.last4,
          card_expiration:    Date.new(card.exp_year, card.exp_month, 1),
          card_type:          card.respond_to?(:brand) ? card.brand : card.type
        )
        subscription.finish!
      rescue Stripe::StripeError => e
        subscription.update_attributes(error: e.message)
        subscription.fail!
      rescue RuntimeError => e
        subscription.update_attributes(error: e.message)
        subscription.fail!
      end

      subscription
    end

  end
end


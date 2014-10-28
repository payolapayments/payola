module Payola
  class CreateStripeSubscription

    def self.call(subscription)
      subscription.save!
      secret_key = Payola.secret_key_for_sale(subscription)

      begin
        if subscription.subscribable.present?
          customer = Stripe::Customer.retrieve(subscription.subscribable.stripe_customer_id)
        else
          customer = Stripe::Customer.create({
            card: subscription.stripe_token,
            email: subscription.email
            }, secret_key)
        end

        stripe_sub = customer.subscriptions.create(
          plan: subscription.plan.stripe_id
        )

        subscription.stripe_id = stripe_sub.id
        subscription.save!
        subscription.finish!
      rescue Stripe::Error => e
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

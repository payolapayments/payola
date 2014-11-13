module Payola
  class ChangeSubscriptionPlan
    def self.call(subscription, plan)
      secret_key = Payola.secret_key_for_sale(subscription)
      old_plan = subscription.plan

      begin
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
        sub = customer.subscriptions.retrieve(subscription.stripe_id)

        sub.plan = plan.stripe_id
        sub.save

        subscription.plan = plan
        subscription.save!

        subscription.instrument_plan_changed(old_plan)

      rescue RuntimeError, Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end
  end
end

module Payola
  class ChangeSubscriptionPlan
    def self.call(subscription, plan, quantity = 1, coupon_code = nil, trial_end = nil)
      secret_key = Payola.secret_key_for_sale(subscription)
      old_plan = subscription.plan

      begin
        sub = retrieve_subscription_for_customer(subscription, secret_key)
        sub.plan = plan.stripe_id
        sub.prorate = should_prorate?(subscription, plan, coupon_code)
        sub.coupon = coupon_code if coupon_code.present?
        sub.quantity = quantity
        sub.trial_end = trial_end if trial_end.present?
        sub.save

        subscription.cancel_at_period_end = false
        subscription.plan = plan
        subscription.quantity = quantity
        subscription.save!

        subscription.instrument_plan_changed(old_plan)

      rescue RuntimeError, Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end

    def self.retrieve_subscription_for_customer(subscription, secret_key)
      customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
      customer.subscriptions.retrieve(subscription.stripe_id)
    end

    def self.should_prorate?(subscription, plan, coupon_code)
      prorate = plan.respond_to?(:should_prorate?) ? plan.should_prorate?(subscription) : true
      prorate = false if coupon_code.present?
      prorate
    end
  end
end

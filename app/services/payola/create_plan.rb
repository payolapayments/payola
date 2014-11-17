module Payola
  class CreatePlan
    def self.call(plan)
      secret_key = Payola.secret_key_for_sale(plan)

      Stripe::Plan.create({
        id:                plan.stripe_id,
        amount:            plan.amount,
        interval:          plan.interval,
        interval_count:    plan.interval_count,
        currency:          plan.respond_to?(:currency) ? plan.currency : Payola.default_currency,
        name:              plan.name,
        trial_period_days: plan.respond_to?(:trial_period_days) ? plan.trial_period_days : nil
      }, secret_key)
    end
  end
end

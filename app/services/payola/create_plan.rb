module Payola
  class CreatePlan
    def self.call(subscription_plan)
      Stripe::Plan.create(
        :id => subscription_plan.stripe_id,
        :amount => subscription_plan.amount,
        :interval => subscription_plan.interval,
        :interval_count => subscription_plan.interval_count,
        :currency => subscription_plan.respond_to?(:currency) ? subscription_plan.currency : Payola.default_currency,
        :name => subscription_plan.name,
        :trial_period_days => subscription_plan.trial_period_days
      )
    end
  end
end

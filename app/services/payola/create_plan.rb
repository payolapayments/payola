module Payola
  class CreatePlan
    def self.call(params)
      klass = params[:plan_class]
      id    = params[:plan_id]
      subscription_plan = klass.find(id)

      begin
        plan = Stripe::Plan.create(
          :id => subscription_plan.stripe_id,
          :amount => subscription_plan.amount,
          :interval => subscription_plan.interval,
          :interval_count => subscription_plan.interval_count,
          :currency => subscription_plan.respond_to?(:currency) ? subscription_plan.currency : Payola.default_currency,
          :name => subscription_plan.name,
          :trial_period_days => subscription_plan.trial_period_days
        )
      rescue Stripe::StripeError => e
        # not sure what to do here...
        puts "something has gone wrong while creating the plan at Stripe"
        raise
      end

    end
  end
end

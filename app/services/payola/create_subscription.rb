module Payola
  class CreateSubscription
    def self.call(params, owner=nil)
      plan = params[:plan]
      affiliate = params[:affiliate]

      sub = Payola::Subscription.new do |s|
        s.plan = plan
        s.email = params[:stripeEmail]
        s.stripe_token = params[:stripeToken] if plan.amount > 0
        s.affiliate_id = affiliate.try(:id)
        s.currency = plan.respond_to?(:currency) ? plan.currency : Payola.default_currency
        s.coupon = params[:coupon]
        s.signed_custom_fields = params[:signed_custom_fields]
        s.setup_fee = params[:setup_fee]
        s.quantity = params[:quantity]
        s.trial_end = params[:trial_end]
        s.tax_percent = params[:tax_percent]
        s.stripe_customer_id = params[:stripe_customer_id]

        s.owner = owner
        s.amount = plan.amount
      end
      
      Payola.queue!(Payola::ProcessSubscription, sub.guid) if sub.save

      sub
    end
  end
end

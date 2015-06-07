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

        s.owner = owner
        s.amount = plan.amount
      end

      if sub.save
        puts "HOLY SHIT THE SUBSCRIPTION SAVED"
        Payola.queue!(Payola::ProcessSubscription, sub.guid)
      else
        puts "THE SUBSCRIPTION DID NOT SAVE!"
      end

      sub
    end
  end
end

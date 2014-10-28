module Payola
  class CreateSubscription
    def self.call(params)
      plan         = params[:plan]
      affiliate    = params[:affiliate]
      coupon       = params[:coupon]

      Payola::Subscription.new do |s|
        s.plan                 = params[:plan]
        s.email                = params[:stripeEmail]
        s.stripe_token         = params[:stripeToken]
        s.affiliate_id         = affiliate.try(:id)
        s.currency             = plan.respond_to?(:currency) ? subscribable.currency : 'usd'
        s.signed_custom_fields = params[:signed_custom_fields]

        if coupon
          s.coupon = coupon
        end
      end

    end
  end
end

      

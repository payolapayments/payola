module Payola
  class SubscriptionsController < ApplicationController
    before_filter :find_plan_and_coupon_and_affiliate, only: [:create]

    def show
      subscription = Subscription.find_by!(guid: params[:guid])
      plan = subscription.plan

      new_path = plan.respond_to?(:redirect_path) ? plan.redirect_path(subscription) : '/'
      redirect_to new_path
    end

    def status
      @subscription = Subscription.where(guid: params[:guid]).first
      render nothing: true, status: 404 and return unless @subscription
      render json: {guid: @subscription.guid, status: @subscription.state, error: @subscription.error}
    end

    def create
      create_params = params.permit!.merge(
        plan: @plan,
        coupon: @coupon,
        affiliate: @affiliate
      )

      @subscription = CreateSubscription.call(create_params)

      if @subscription.save
        Payola.queue!(Payola::ProcessSubscription, @subscription.guid)
        render json: { guid: @subscription.guid }
      else
        render json: { error: @subscription.errors.full_messages.join(". ") }, status: 400
      end
    end

    def destroy
      subscription = Subscription.find_by!(guid: params[:guid])
      Payola::CancelSubscription.call(subscription)
      redirect_to confirm_subscription_path(subscription)
    end

    private
    def find_plan_and_coupon_and_affiliate
      @plan_class = Payola.subscribables[params[:plan_class]]

      raise ActionController::RoutingError.new('Not Found') unless @plan_class && @plan_class.subscribable?

      @plan = @plan_class.find_by!(id: params[:plan_id])
      #coupon_code = cookies[:cc] || params[:cc] || params[:coupon_code]

      #@coupon = Coupon.where('lower(code) = lower(?)', coupon_code).first
      #if @coupon
        #cookies[:cc] = coupon_code
        #@price = @product.price * (1 - @coupon.percent_off / 100.0)
      #else
        #@price = @product.price
      #end

      #affiliate_code = cookies[:aff] || params[:aff]
      #@affiliate = Affiliate.where('lower(code) = lower(?)', affiliate_code).first
      #if @affiliate
        #cookies[:aff] = affiliate_code
      #end

    end

  end
end

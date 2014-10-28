module Payola
  class SubscriptionsController < ApplicationController
    before_filter :find_plan, only: [:create]
    
    def create
      create_params = params.permit!.merge(
        plan: @plan
      )

      @subscription = CreateSubscription.call(create_params)

      if @subscription.save
        Payola.queue!(ProcessSubscription, @subscription.guid)
        render json: { guid: @subscription.guid }
      else
        render json: { error: @subscription.errors.full_messages.join(". ") }, status: 400
      end
    end

    def status
      @subscription = Subscription.where(guid: params[:guid]).first
      render nothing: true, status: 404 and return unless @subscription
      render json: { guid: @subscription.guid, status: @subscription.state, error: @subscription.error }
    end

    private

    def find_plan
      @plan = Payola::Plan.find_by(permalink: params[:plan])
      raise ActionController::RoutingError.new('Not Found') unless @product_class && @product_class.subscribable?

      affiliate_code = cookies[:aff] || params[:aff]
      @affiliate = Affiliate.where('lower(code) = lower(?)', affiliate_code).first
      if @affiliate
        cookies[:aff] = affiliate_code
      end
    end
  end
end

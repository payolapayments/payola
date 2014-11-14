module Payola
  class SubscriptionsController < ApplicationController
    before_filter :find_plan_and_coupon_and_affiliate, only: [:create, :change_plan]
    before_filter :check_modify_permissions, only: [:destroy, :change_plan, :update_card]

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

    def change_plan
      subscription = Subscription.find_by!(guid: params[:guid])
      Payola::ChangeSubscriptionPlan.call(subscription, @plan)

      if subscription.valid?
        redirect_to confirm_subscription_path(subscription), notice: "Subscription plan updated"
      else
        redirect_to confirm_subscription_path(subscription), alert: subscription.errors.full_messages.to_sentence
      end
    end

    def update_card
      subscription = Subscription.find_by!(guid: params[:guid])
      Payola::UpdateCard.call(subscription, params[:stripeToken])

      if subscription.valid?
        redirect_to confirm_subscription_path(subscription), notice: "Card updated"
      else
        redirect_to confirm_subscription_path(subscription), alert: subscription.errors.full_messages.to_sentence
      end
    end

    private

    def find_plan_and_coupon_and_affiliate
      @plan_class = Payola.subscribables[params[:plan_class]]

      raise ActionController::RoutingError.new('Not Found') unless @plan_class && @plan_class.subscribable?

      @plan = @plan_class.find_by!(id: params[:plan_id])
      
      @coupon = cookies[:cc] || params[:cc] || params[:coupon_code] || params[:coupon]

      affiliate_code = cookies[:aff] || params[:aff]
      @affiliate = Affiliate.where('lower(code) = lower(?)', affiliate_code).first
      if @affiliate
        cookies[:aff] = affiliate_code
      end

    end

    def check_modify_permissions
      subscription = Subscription.find_by!(guid: params[:guid])
      if self.respond_to?(:payola_can_modify_subscription?)
        redirect_to(
          confirm_subscription_path(subscription),
          alert: "You cannot modify this subscription."
        ) and return unless self.payola_can_modify_subscription?(subscription)
      end
    end
  end
end

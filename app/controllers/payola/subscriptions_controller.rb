module Payola
  class SubscriptionsController < ApplicationController
    include Payola::AffiliateBehavior
    include Payola::StatusBehavior
    include Payola::AsyncBehavior

    before_filter :find_plan_coupon_and_quantity, only: [:create, :change_plan]
    before_filter :check_modify_permissions, only: [:destroy, :change_plan, :change_quantity, :update_card]

    def show
      show_object(Subscription)
    end

    def status
      object_status(Subscription)
    end

    def create
      create_object(Subscription, CreateSubscription, nil, :plan, @plan)
    end

    def destroy
      subscription = Subscription.find_by!(guid: params[:guid])
      Payola::CancelSubscription.call(subscription)
      redirect_to confirm_subscription_path(subscription)
    end

    def change_plan
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::ChangeSubscriptionPlan.call(@subscription, @plan)

      confirm_with_message("Subscription plan updated")
    end

    def change_quantity
      find_quantity
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::ChangeSubscriptionQuantity.call(@subscription, @quantity)

      confirm_with_message("Subscription quantity updated")
    end

    def update_card
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::UpdateCard.call(@subscription, params[:stripeToken])

      confirm_with_message("Card updated")
    end

    private

    def find_plan_coupon_and_quantity
      find_plan
      find_coupon
      find_quantity
    end

    def find_plan
      @plan_class = Payola.subscribables[params[:plan_class]]

      raise ActionController::RoutingError.new('Not Found') unless @plan_class && @plan_class.subscribable?

      @plan = @plan_class.find_by!(id: params[:plan_id])
    end

    def find_coupon
      @coupon = cookies[:cc] || params[:cc] || params[:coupon_code] || params[:coupon]
    end

    def find_quantity
      @quantity = params[:quantity].blank? ? 1 : params[:quantity].to_i
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

    def confirm_with_message(message)
      if @subscription.valid?
        redirect_to confirm_subscription_path(@subscription), notice: message
      else
        redirect_to confirm_subscription_path(@subscription), alert: @subscription.errors.full_messages.to_sentence
      end
    end

  end
end

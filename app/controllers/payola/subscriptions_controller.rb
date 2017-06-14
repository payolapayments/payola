module Payola
  class SubscriptionsController < ApplicationController
    include Payola::AffiliateBehavior
    include Payola::StatusBehavior
    include Payola::AsyncBehavior

    before_action :find_plan_coupon_quantity_and_trial_end, only: [:create, :change_plan]
    before_action :check_modify_permissions, only: [:destroy, :change_plan, :change_quantity, :update_card]

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
      Payola::CancelSubscription.call(subscription, at_period_end: to_boolean(params[:at_period_end]))
      redirect_to confirm_subscription_path(subscription)
    end

    def change_plan
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::ChangeSubscriptionPlan.call(@subscription, @plan, @quantity, @coupon, @trial_end)

      confirm_with_message(t('payola.subscriptions.plan_updated'))
    end

    def change_quantity
      find_quantity
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::ChangeSubscriptionQuantity.call(@subscription, @quantity)

      confirm_with_message(t('payola.subscriptions.quantity_updated'))
    end

    def update_card
      @subscription = Subscription.find_by!(guid: params[:guid])
      Payola::UpdateCard.call(@subscription, params[:stripeToken])

      confirm_with_message(t('payola.subscriptions.card_updated'))
    end

    private

    def find_plan_coupon_quantity_and_trial_end
      find_plan
      find_coupon
      find_trial_end
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

    def find_trial_end
      @trial_end = params[:trial_end]
    end

    def find_quantity
      @quantity = params[:quantity].blank? ? 1 : params[:quantity].to_i
    end

    def check_modify_permissions
      subscription = Subscription.find_by!(guid: params[:guid])
      if self.respond_to?(:payola_can_modify_subscription?)
        redirect_to(
          confirm_subscription_path(subscription),
          alert: t('payola.subscriptions.not_authorized')
        ) and return unless self.payola_can_modify_subscription?(subscription)
      else
        raise NotImplementedError.new("Please implement ApplicationController#payola_can_modify_subscription?")
      end
    end

    def confirm_with_message(message)
      if @subscription.errors.empty?
        redirect_to confirm_subscription_path(@subscription), notice: message
      else
        redirect_to confirm_subscription_path(@subscription), alert: @subscription.errors.full_messages.to_sentence
      end
    end

    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set

    def to_boolean(value)
      TRUE_VALUES.include?(value)
    end

  end
end

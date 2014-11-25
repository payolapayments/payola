class SubscribeController < ApplicationController
  helper Payola::PriceHelper
  include Payola::StatusBehavior

  def index
    @plan = SubscriptionPlan.first
  end

  def show
    @subscription = Payola::Subscription.find_by!(guid: params[:guid])
  end

  def create
    params[:plan] = SubscriptionPlan.first
    subscription = Payola::CreateSubscription.call(params)
    render_payola_status(subscription)
  end
end

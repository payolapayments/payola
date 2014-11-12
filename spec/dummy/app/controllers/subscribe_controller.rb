class SubscribeController < ApplicationController
  helper Payola::PriceHelper

  def index
    @plan = SubscriptionPlan.first
  end

  def show
    @subscription = Payola::Subscription.find_by!(guid: params[:guid])
  end
end

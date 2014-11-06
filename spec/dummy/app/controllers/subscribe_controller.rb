class SubscribeController < ApplicationController
  helper Payola::PriceHelper

  def index
    @plan = SubscriptionPlan.first
  end
end

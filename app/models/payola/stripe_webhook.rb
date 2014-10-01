module Payola
  class StripeWebhook < ActiveRecord::Base
    validates_uniqueness_of :stripe_id
  end
end

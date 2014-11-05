module Payola
  class Subscription < ActiveRecord::Base

    validates_presence_of :plan_id
    validates_presence_of :plan_type

    belongs_to :plan, :polymorphic => true
  end
end

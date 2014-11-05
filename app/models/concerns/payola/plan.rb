require 'active_support/concern'

module Payola
  module Plan
    extend ActiveSupport::Concern

    included do
      validates_presence_of :amount
      validates_presence_of :interval
      validates_presence_of :interval_count
      validates_presence_of :stripe_id
      validates_presence_of :name

      validates_uniqueness_of :stripe_id

      after_save :queue_create_stripe_plan, on: :create
    end

    def queue_create_stripe_plan
      Payola.queue!(Payola::CreatePlan, {
        plan_class: self.class.to_s,
        plan_id: self.id
      })
    end

  end
end

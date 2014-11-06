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

      before_save :create_stripe_plan, on: :create

      has_many :subscriptions, :class_name => "Payola::Subscription"

      Payola.register_subscribable(self)
    end

    def create_stripe_plan
      Payola::CreatePlan.call(self)
    end

    def plan_class
      self.class.plan_class
    end

    module ClassMethods
      def subscribable?
        true
      end

      def plan_class
        self.to_s.underscore
      end
    end

  end
end

require 'active_support/concern'

module Payola
  module Plan
    extend ActiveSupport::Concern

    included do
      validates_presence_of :amount
      validates_presence_of :interval
      validates_presence_of :stripe_id
      validates_presence_of :name

      validates_uniqueness_of :stripe_id

      before_create :create_stripe_plan, if: -> { Payola.create_stripe_plans }

      has_many :subscriptions, :class_name => "Payola::Subscription", as: :plan,
        dependent: :restrict_with_exception

      Payola.register_subscribable(self)
    end

    def create_stripe_plan
      Payola::CreatePlan.call(self)
    end

    def plan_class
      self.class.plan_class
    end

    def product_class
      plan_class
    end

    def price
      amount
    end

    module ClassMethods
      def subscribable?
        true
      end

      def plan_class
        self.to_s.underscore.parameterize
      end
    end

  end
end

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
    end
  end
end

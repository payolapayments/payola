require 'active_support/concern'

module Payola
  module Sellable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :name
      validates_presense_of :permalink
      validates_uniqueness_of :permalink
    end

    module ClassMethods
      def sellable?
        true
      end
    end
  end
end

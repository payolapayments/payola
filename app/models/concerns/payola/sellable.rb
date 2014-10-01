require 'active_support/concern'

module Payola
  module Sellable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :name
      validates_presence_of :permalink
      validates_uniqueness_of :permalink
    end

    def product_class
      self.class.to_s.underscore
    end

    module ClassMethods
      def sellable?
        true
      end
    end
  end
end

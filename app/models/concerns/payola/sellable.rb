require 'active_support/concern'

module Payola
  module Sellable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :name
      validates_presence_of :permalink
      validates_presence_of :price
      validates_uniqueness_of :permalink

      Payola.register_sellable(self)
    end

    def product_class
      self.class.product_class
    end

    module ClassMethods
      def sellable?
        true
      end

      def product_class
        self.to_s.underscore
      end
    end
  end
end

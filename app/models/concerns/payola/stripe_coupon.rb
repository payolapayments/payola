require 'active_support/concern'

module Payola
  module StripeCoupon
    extend ActiveSupport::Concern

    included do
      validate :amount_off_or_percent_of_present
      validates_presence_of :duration
      validates :duration, inclusion: { in: %w(once forever repeating),
                                        message: "%{value} is not a valid duration." }
      validate :duration_in_months_conditional
      validates_presence_of :stripe_id

      def amount_off_or_percent_of_present
        if amount_off.blank? && percent_off.blank?
          errors.add(:amount_off, "or percent_off must be present.")
        elsif amount_off.present? && percent_off.present?
          errors.add(:amount_off, "or percent_off should be present, not both.")
        end
      end

      def duration_in_months_conditional
        if duration == 'repeating' && duration_in_months.blank?
          errors.add(:duration_in_months,"must be present for repeating duration.")
        end
      end


      before_save :create_stripe_coupon, on: :create


      Payola.register_saveable(self)
    end

    def create_stripe_coupon
      Payola::CreateStripeCoupon.call(self)
    end

    def coupon_class
      self.class.coupon_class
    end

    def product_class
      coupon_class
    end

    module ClassMethods
      def saveable? # bargainable? thriftable?
        true
      end

      def coupon_class
        self.to_s.underscore
      end
    end

  end
end

module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
    validates :duration, inclusion: { in: %w( once repeating forever ) }
    validates_presence_of :duration_in_months, if: lambda { duration == "repeating" }
  end
end

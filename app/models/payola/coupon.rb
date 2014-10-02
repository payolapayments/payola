module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
  end
end

module Payola
  class Coupon < ActiveRecord::Base
    validates_uniqueness_of :code
    validates_presence_of :duration
  end
end

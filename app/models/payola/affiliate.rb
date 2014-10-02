module Payola
  class Affiliate < ActiveRecord::Base
    validates_uniqueness_of :code
  end
end

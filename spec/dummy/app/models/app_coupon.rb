class AppCoupon < ActiveRecord::Base
  include Payola::StripeCoupon
end

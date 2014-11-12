# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :app_coupon do
    percent_off nil
    amount_off 1
    currency "usa"
    duration "forever"
    duration_in_months 2
    stripe_id "my-coupon"
    max_redemptions 1
    redeem_by "2014-11-11 22:16:51"
  end
end

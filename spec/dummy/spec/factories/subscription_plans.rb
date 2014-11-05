# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription_plan do
    amount 1
    interval "MyString"
    interval_count 1
    name "MyString"
    stripe_id "MyString"
    trial_period_days 1
  end
end

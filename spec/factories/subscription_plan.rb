FactoryGirl.define do
  factory :subscription_plan do
    name "Foo"
    sequence(:stripe_id) { |n| "foo-#{n}" }
    amount 100
    interval "month"
    interval_count 1
  end
end

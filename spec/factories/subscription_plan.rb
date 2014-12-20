FactoryGirl.define do
  factory :subscription_plan do
    sequence(:name) { |n| "Foo #{n}" }
    sequence(:stripe_id) { |n| "foo-#{n}" }
    amount 100
    interval "month"
    interval_count 1
  end

  factory :subscription_plan_without_interval_count do
    sequence(:name) { |n| "Foo Without Interval #{n}" }
    sequence(:stripe_id) { |n| "foo-without-interval-#{n}" }
    amount 100
    interval "month"
  end
end

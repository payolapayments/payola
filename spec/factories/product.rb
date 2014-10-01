FactoryGirl.define do
  factory :product do
    name "Foo"
    sequence(:permalink) { |n| "foo-#{n}" }
    price 100
  end
end

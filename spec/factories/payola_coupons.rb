# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payola_coupon, :class => 'Payola::Coupon' do
    code "MyString"
    percent_off 1

    duration 'once'
    max_redemptions 1
    redeem_by 1.day.from_now

    trait :flat_amount do
      percent_off nil
      amount_off 2
      currency 'USD'
    end

    trait :repeating do
      duration 'repeating'
      duration_in_months 1
    end

    trait :perpetual do
      duration 'forever'
    end

    trait :expired do
      redeem_by 1.day.ago
    end
  end
end

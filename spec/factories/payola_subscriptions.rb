# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription, :class => 'Payola::Subscription' do
    plan_type "SubscriptionPlan"
    plan_id 1
    start "2014-11-04 22:34:39"
    status "MyString"
    owner_type "Owner"
    owner_id 1
    cancel_at_period_end false
    current_period_start "2014-11-04 22:34:39"
    current_period_end "2014-11-04 22:34:39"
    ended_at "2014-11-04 22:34:39"
    trial_start Time.now
    trial_end Time.now + 7.days
    canceled_at "2014-11-04 22:34:39"
    email "jeremy@octolabs.com"
    stripe_token "yyz123"
    currency 'usd'
    quantity 1
    stripe_id 'sub_123456'
  end
end

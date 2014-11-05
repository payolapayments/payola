# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription, :class => 'Payola::Subscription' do
    plan_type "MyString"
    plan_id 1
    start "2014-11-04 22:34:39"
    status "MyString"
    owner_type "MyString"
    owner_id 1
    stripe_customer_id "MyString"
    cancel_at_period_end false
    current_period_start "2014-11-04 22:34:39"
    current_period_end "2014-11-04 22:34:39"
    ended_at "2014-11-04 22:34:39"
    trial_start "2014-11-04 22:34:39"
    trial_end "2014-11-04 22:34:39"
    canceled_at "2014-11-04 22:34:39"
    quantity 1
  end
end

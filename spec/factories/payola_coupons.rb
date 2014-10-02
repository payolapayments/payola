# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payola_coupon, :class => 'Coupon' do
    code "MyString"
    percent_off 1
  end
end

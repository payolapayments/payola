# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payola_affiliate, :class => 'Affiliate' do
    code "MyString"
    email "MyString"
    percent 1
  end
end

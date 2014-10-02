# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payola_affiliate, :class => 'Payola::Affiliate' do
    code "MyString"
    email "foo@example.com"
    percent 100
  end
end

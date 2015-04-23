FactoryGirl.define do
  factory :sale, class: Payola::Sale do
    email 'test@example.com'
    product
    stripe_token 'tok_test'
    currency 'usd'
    amount 100
  end
end

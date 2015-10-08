require 'spec_helper'

module Payola
  describe CreateCard do
    let(:stripe_helper) { StripeMock.create_test_helper }
  
    let(:customer) {
      Stripe::Customer.create({
        email: 'johnny@appleseed.com',
      })
    }

    describe "#call" do
      it "creates the new card" do
        Payola.secret_key = 'sk_test_12345'

        token = StripeMock.generate_card_token({last4: '1111', exp_year: '2099', exp_month: '12', brand: 'JWH'})
        expect{Payola::CreateCard.call(customer.id, token)}.to_not raise_error
        updated_customer = Stripe::Customer.retrieve(customer.id, Payola.secret_key)
        expect(updated_customer.sources.first.last4).to eq('1111')
      end

      it "does not create duplicate cards" do
        Payola.secret_key = 'sk_test_12345'

        token = StripeMock.generate_card_token({last4: '1111', exp_year: '2099', exp_month: '12', brand: 'JWH'})
        token2 = StripeMock.generate_card_token({last4: '1111', exp_year: '2099', exp_month: '12', brand: 'JWH'})

        expect{Payola::CreateCard.call(customer.id, token)}.to_not raise_error

        updated_customer = Stripe::Customer.retrieve(customer.id, Payola.secret_key)
        expect(updated_customer.sources.count).to eq 1

        expect{Payola::CreateCard.call(customer.id, token2)}.to_not raise_error

        updated_customer = Stripe::Customer.retrieve(customer.id, Payola.secret_key)
        expect(updated_customer.sources.count).to eq 1
      end

    end
  end
end

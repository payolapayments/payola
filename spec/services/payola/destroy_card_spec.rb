require 'spec_helper'

module Payola
  describe DestroyCard do
    let(:stripe_helper) { StripeMock.create_test_helper }
  
    let(:customer) {
      Stripe::Customer.create({
        email: 'johnny@appleseed.com',
        source: stripe_helper.generate_card_token
      })
    }

    describe "#call" do
      it "creates the new card" do
        Payola.secret_key = 'sk_test_12345'
        
        card_id = customer.sources.first.id
  
        expect{Payola::DestroyCard.call(card_id, customer.id)}.to_not raise_error
        updated_customer = Stripe::Customer.retrieve(customer.id, Payola.secret_key)
        expect(updated_customer.sources.count).to eq(0)
        expect(updated_customer.default_source).to eq(nil)
      end
  
    end
  end
end

require 'spec_helper'

module Payola
  describe UpdateCustomer do
    let(:stripe_helper) { StripeMock.create_test_helper }
  
    let(:customer) {
      Stripe::Customer.create({
        email: 'johnny@appleseed.com',
        card: stripe_helper.generate_card_token({last4: '2233', exp_year: '2021', exp_month: '11', brand: 'JCB'})
      })
    }

    describe "#call" do
      it "updates the customer" do
        Payola.secret_key = 'sk_test_12345'

        options = { default_source: "1234" }
        expect{Payola::UpdateCustomer.call(customer.id, options)}.to_not raise_error
        updated_customer = Stripe::Customer.retrieve(customer.id, Payola.secret_key)
        expect(updated_customer.default_source).to eq "1234"
      end
  
    end
  end
end

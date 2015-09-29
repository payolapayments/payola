require 'spec_helper'

module Payola
  describe CustomersController do
    routes { Payola::Engine.routes }
  
    before do
      request.env["HTTP_REFERER"] = "/my/cards"
    end

    describe '#update' do
      let(:stripe_helper) { StripeMock.create_test_helper }

      let(:customer) {
        Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          card: stripe_helper.generate_card_token({last4: '2233', exp_year: '2021', exp_month: '11', brand: 'JCB'})
        })
      }

      it "should pass args to UpdateCustomer" do
        expect(UpdateCustomer).to receive(:call)
        post :update, id: customer.id, customer: { default_source: "1234" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Succesfully updated customer"
        expect(flash[:alert]).to_not be_present
      end

    end
  end
end

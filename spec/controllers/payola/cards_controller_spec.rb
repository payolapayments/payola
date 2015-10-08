require 'spec_helper'

module Payola
  describe CardsController do
    routes { Payola::Engine.routes }
  
    before do
      request.env["HTTP_REFERER"] = "/my/cards"
    end

    describe '#create' do
      let(:stripe_helper) { StripeMock.create_test_helper }

      let(:customer) {
        Stripe::Customer.create({
          email: 'johnny@appleseed.com',
        })
      }

      it "should pass args to CreateCard" do
        expect(CreateCard).to receive(:call)
        post :create, customer_id: customer.id, stripeToken: StripeMock.generate_card_token({})

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Succesfully created new card"
        expect(flash[:alert]).to_not be_present
      end

      it "should fail when missing a token" do
        expect(CreateCard).to_not receive(:call)
        post :create, customer_id: customer.id, stripeToken: nil

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:alert]).to eq "Could not create new card"
        expect(flash[:notice]).to_not be_present
      end
    end

    describe '#destroy' do
      let(:stripe_helper) { StripeMock.create_test_helper }

      let(:customer) {
        Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })
      }

      it "should pass args to DestroyCard" do
        expect(DestroyCard).to receive(:call)
        delete :destroy, id: customer.sources.first.id, customer_id: customer.id

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Succesfully removed the card"
        expect(flash[:alert]).to_not be_present
      end
    end

  end
end

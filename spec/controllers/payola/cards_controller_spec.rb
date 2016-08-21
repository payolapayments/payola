require 'spec_helper'

module Payola
  describe CardsController do
    routes { Payola::Engine.routes }

    before do
      Payola.secret_key = 'sk_test_12345'
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
        post :create, params: { customer_id: customer.id, stripeToken: StripeMock.generate_card_token({}) }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Successfully created new card"
        expect(flash[:alert]).to_not be_present
      end

      it "should fail when missing a token" do
        expect(CreateCard).to_not receive(:call)
        post :create, params: { customer_id: customer.id, stripeToken: nil }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:alert]).to eq "Could not create new card"
        expect(flash[:notice]).to_not be_present
      end

      it "should return to the passed return path" do
        post :create, params: { customer_id: customer.id, stripeToken: StripeMock.generate_card_token({}), return_to: "/another/path" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/another/path"
      end

      context "authorization" do
        it "should permit authorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(true)
          expect(controller).to receive(:create).and_call_original

          post :create, params: { customer_id: customer.id, stripeToken: StripeMock.generate_card_token({}) }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to_not be_present
        end

        it "should deny unauthorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(false)
          expect(controller).to_not receive(:create)

          post :create, params: { customer_id: customer.id, stripeToken: StripeMock.generate_card_token({}) }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to eq "You cannot modify this customer."
        end
      end

      it "should raise error when no referrer to redirect to" do
        request.env.delete("HTTP_REFERER")

        expect do
          post :create, params: {
            customer_id: customer.id,
            stripeToken: StripeMock.generate_card_token({})
          }
        end.to raise_error(ActionController::RedirectBackError)
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
        delete :destroy, params: { id: customer.sources.first.id, customer_id: customer.id }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Successfully removed the card"
        expect(flash[:alert]).to_not be_present
      end

      it "should not call DestroyCard when params blank" do
        expect(DestroyCard).to_not receive(:call)
        delete :destroy, params: { id: "", customer_id: "" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:alert]).to eq "Could not remove the card"
        expect(flash[:notice]).to_not be_present
      end

      it "should return to the passed return path" do
        delete :destroy, params: { id: customer.sources.first.id, customer_id: customer.id, return_to: "/another/path" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/another/path"
      end

      context "authorization" do
        it "should permit authorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(true)
          expect(controller).to receive(:destroy).and_call_original

          delete :destroy, params: { id: customer.sources.first.id, customer_id: customer.id }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to_not be_present
        end

        it "should deny unauthorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(false)
          expect(controller).to_not receive(:destroy)

          delete :destroy, params: { id: customer.sources.first.id, customer_id: customer.id }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to eq "You cannot modify this customer."
        end

        it "should throw error if controller doesn't define payola_can_modify_customer?" do
          controller.instance_eval('undef :payola_can_modify_customer?')

          expect {
            delete :destroy, params: { id: customer.sources.first.id, customer_id: customer.id }
          }.to raise_error(NotImplementedError)
      end
      end

      it "should raise error when no referrer to redirect to" do
        request.env.delete("HTTP_REFERER")

        expect do
          delete :destroy, params: {
            id: customer.sources.first.id, customer_id: customer.id
          }
        end.to raise_error(ActionController::RedirectBackError)
      end

    end

  end
end

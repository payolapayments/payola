require 'spec_helper'

module Payola
  describe CustomersController do
    routes { Payola::Engine.routes }

    before do
      Payola.secret_key = 'sk_test_12345'
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
        post :update, params: { id: customer.id, customer: { default_source: "1234" } }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:notice]).to eq "Successfully updated customer"
        expect(flash[:alert]).to_not be_present
      end

      it "should return to the passed return path" do
        post :update, params: { id: customer.id, customer: { default_source: "1234" }, return_to: "/another/path" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/another/path"
      end

      it "should not invoke UpdateCustomer if id param is not present" do
        expect(UpdateCustomer).to_not receive(:call)

        post :update, params: { id: "" }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/cards"
        expect(flash[:alert]).to eq "Could not update customer"
        expect(flash[:notice]).to_not be_present
      end

      context "authorization" do
        it "should permit authorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(true)
          expect(controller).to receive(:update).and_call_original

          post :update, params: { id: customer.id, customer: { default_source: "1234" } }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to_not be_present
        end

        it "should deny unauthorized requests" do
          allow(controller).to receive(:payola_can_modify_customer?).with(customer.id).and_return(false)
          expect(controller).to_not receive(:update)

          post :update, params: { id: customer.id, customer: { default_source: "1234" } }

          expect(response).to redirect_to "/my/cards"
          expect(flash[:alert]).to eq "You cannot modify this customer."
        end
      end

      it "should raise error when no referrer to redirect to" do
        request.env.delete("HTTP_REFERER")

        expect do
          post :update, params: {
            id: customer.id, customer: { default_source: "1234" }
          }
        end.to raise_error(ActionController::RedirectBackError)
      end

    end
  end
end

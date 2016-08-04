require 'spec_helper'

module Payola
  describe CouponsController do
    routes { Payola::Engine.routes }
  
    before do
      Payola.secret_key = 'sk_test_12345'
      Payola.create_stripe_coupons = false
      request.env["HTTP_REFERER"] = "/my/coupons"
    end

    describe '#create' do

      it "creates a coupon" do
        expect(CreateCoupon).not_to receive(:call)
        post :create, coupon: { code: 'savings', duration: 'once', amount_off: 10 }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/coupons"
        expect(flash[:notice]).to eq "Succesfully created new coupon"
        expect(flash[:alert]).to_not be_present
      end

      it "passes args to CreateCoupon" do
        Payola.create_stripe_coupons = true

        expect(CreateCoupon).to receive(:call)
        post :create, coupon: { code: 'savings', duration: 'once', amount_off: 10 }

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/coupons"
        expect(flash[:notice]).to eq "Succesfully created new coupon"
        expect(flash[:alert]).to_not be_present
      end

      it "returns to the passed return path" do
        post :create, coupon: { code: 'savings', duration: 'once', amount_off: 10 }, return_to: "/another/path"

        expect(response.status).to eq 302
        expect(response).to redirect_to "/another/path"
      end
    end

    describe '#destroy' do

      let(:coupon) { create :payola_coupon }

      it "destroys the coupon" do
        expect(DestroyCoupon).not_to receive(:call)
        delete :destroy, id: coupon.id

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/coupons"
        expect(flash[:notice]).to eq "Succesfully removed the coupon"
        expect(flash[:alert]).to_not be_present
      end

      it "passes args to DestroyCoupon" do
        Payola.create_stripe_coupons = true

        expect(DestroyCoupon).to receive(:call)
        delete :destroy, id: coupon.id

        expect(response.status).to eq 302
        expect(response).to redirect_to "/my/coupons"
        expect(flash[:notice]).to eq "Succesfully removed the coupon"
        expect(flash[:alert]).to_not be_present
      end

      it "should return to the passed return path" do
        delete :destroy, id: coupon.id, return_to: "/another/path"

        expect(response.status).to eq 302
        expect(response).to redirect_to "/another/path"
      end
    end

  end
end

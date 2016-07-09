require 'spec_helper'

module Payola
  describe TransactionsController do
    routes { Payola::Engine.routes }

    before do
      @product = create(:product)
      Payola.register_sellable(@product.class)
    end

    describe '#create' do
      it "should pass args to CreateSale and queue the job" do
        sale = double
        errors = double
        expect(errors).to receive(:full_messages).and_return([])
        expect(sale).to receive(:state).and_return('pending')
        expect(sale).to receive(:error).and_return(nil)
        expect(sale).to receive(:errors).and_return(errors)
        expect(sale).to receive(:save).and_return(true)
        expect(sale).to receive(:guid).at_least(1).times.and_return('blah')

        expect(CreateSale).to receive(:call).with(
          permitted_params(
            'product_class' => 'product',
            'permalink' => @product.permalink,
            'controller' => 'payola/transactions',
            'action' => 'create',
            'product' => @product,
            'coupon' => nil,
            'affiliate' => nil
          )
        ).and_return(sale)

        expect(Payola).to receive(:queue!)
        post :create, params: { product_class: @product.product_class, permalink: @product.permalink }

        expect(response.status).to eq 200
        parsed_body = JSON.load(response.body)
        expect(parsed_body['guid']).to eq 'blah'
      end

      describe "with an error" do
        it "should return an error in json" do
          sale = double
          expect(sale).to receive(:error).and_return(nil)
          expect(sale).to receive(:save).and_return(false)
          expect(sale).to receive(:state).and_return('failed')
          expect(sale).to receive(:guid).at_least(1).times.and_return('blah')
          error = double
          expect(error).to receive(:full_messages).and_return(['done did broke'])
          expect(sale).to receive(:errors).and_return(error)

          expect(CreateSale).to receive(:call).and_return(sale)
          expect(Payola).to_not receive(:queue!)

          post :create, params: { product_class: @product.product_class, permalink: @product.permalink }

          expect(response.status).to eq 400
          parsed_body = JSON.load(response.body)
          expect(parsed_body['error']).to eq 'done did broke'
        end
      end
    end

    describe '#status' do
      it "should return 404 with no response body if it can't find the sale" do
        get :status, params: { guid: 'doesnotexist' }
        expect(response.status).to eq 404
        expect(response.body).to be_blank
      end
      it "should return json with properties" do
        sale = create(:sale)
        get :status, params: { guid: sale.guid }

        expect(response.status).to eq 200

        parsed_body = JSON.load(response.body)

        expect(parsed_body['guid']).to eq sale.guid
        expect(parsed_body['status']).to eq sale.state
        expect(parsed_body['error']).to be_nil
      end
    end

    describe '#show' do
      it "should redirect to the product's redirect path" do
        sale = create(:sale)
        get :show, params: { guid: sale.guid }

        expect(response).to redirect_to '/'
      end
    end
  end
end

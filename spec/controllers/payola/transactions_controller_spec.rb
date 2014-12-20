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
        errors.should_receive(:full_messages).and_return([])
        sale.should_receive(:state).and_return('pending')
        sale.should_receive(:error).and_return(nil)
        sale.should_receive(:errors).and_return(errors)
        sale.should_receive(:save).and_return(true)
        sale.should_receive(:guid).at_least(1).times.and_return('blah')

        CreateSale.should_receive(:call).with(
          'product_class' => 'product',
          'permalink' => @product.permalink,
          'controller' => 'payola/transactions',
          'action' => 'create',
          'product' => @product,
          'coupon' => nil,
          'affiliate' => nil
        ).and_return(sale)

        Payola.should_receive(:queue!)
        post :create, product_class: @product.product_class, permalink: @product.permalink

        expect(response.status).to eq 200
        parsed_body = JSON.load(response.body)
        expect(parsed_body['guid']).to eq 'blah'
      end

      describe "with an error" do
        it "should return an error in json" do
          sale = double
          sale.should_receive(:error).and_return(nil)
          sale.should_receive(:save).and_return(false)
          sale.should_receive(:state).and_return('failed')
          sale.should_receive(:guid).at_least(1).times.and_return('blah')
          error = double
          error.should_receive(:full_messages).and_return(['done did broke'])
          sale.should_receive(:errors).and_return(error)

          CreateSale.should_receive(:call).and_return(sale)          
          Payola.should_not_receive(:queue!)

          post :create, product_class: @product.product_class, permalink: @product.permalink

          expect(response.status).to eq 400
          parsed_body = JSON.load(response.body)
          expect(parsed_body['error']).to eq 'done did broke'
        end
      end
    end

    describe '#status' do
      it "should return 404 if it can't find the sale" do
        get :status, guid: 'doesnotexist'
        expect(response.status).to eq 404
      end
      it "should return json with properties" do
        sale = create(:sale)
        get :status, guid: sale.guid

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
        get :show, guid: sale.guid

        expect(response).to redirect_to '/'
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe TransactionsController do
    before do
      @product = create(:product)
      Payola.register_sellable(@product.class)
    end

    describe '#create' do
      it "should pass args to CreateSale and queue the job" do
        sale = double
        sale.should_receive(:save).and_return(true)
        sale.should_receive(:guid).at_least(1).times.and_return('blah')

        CreateSale.should_receive(:call).and_return(sale)
        Payola.should_receive(:queue!)
        post :create, product_class: @product.product_class, permalink: @product.permalink, use_route: :payola

        expect(response.status).to eq 200
        parsed_body = JSON.load(response.body)
        expect(parsed_body['guid']).to eq 'blah'
      end

      describe "with an error" do
        it "should return an error in json"
      end
    end

    describe '#status' do
      it "should return 404 if it can't find the sale"
      it "should return json with properties"
    end

    describe '#show' do
      it "should redirect to the product's redirect path"
    end
  end
end

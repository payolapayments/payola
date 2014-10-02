require 'spec_helper'

module Payola
  describe CreateSale do
    before do
      @product = create(:product)
    end

    describe "#call" do
      it "should create a sale" do
        sale = CreateSale.call({
            email: 'pete@bugsplat.info',
            stripeToken: 'test_tok',
          },
          @product,
          nil,
          nil
        )
        expect(sale.email).to eq 'pete@bugsplat.info'
        expect(sale.stripe_token).to eq 'test_tok'
        expect(sale.product_id).to eq @product.id
        expect(sale.product).to eq @product
        expect(sale.product_type).to eq 'Product'
      end
            
      it "should include the affiliate if given"

      describe "with coupon" do
        it "should include the coupon"
        it "should set the price correctly"
      end
    end
  end
end

require 'spec_helper'

module Payola
  describe CreateSale do
    before do
      @product = create(:product)
    end

    describe "#call" do
      it "should create a sale" do
        sale = CreateSale.call(
          stripeEmail: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          product: @product
        )

        expect(sale.email).to eq 'pete@bugsplat.info'
        expect(sale.stripe_token).to eq 'test_tok'
        expect(sale.product_id).to eq @product.id
        expect(sale.product).to eq @product
        expect(sale.product_type).to eq 'Product'
        expect(sale.currency).to eq 'usd'
      end
            
      it "should include the affiliate if given" do
        affiliate = create(:payola_affiliate)
        sale = CreateSale.call(
          email: 'pete@bugsplat.info',
          stripeToken: 'test_tok',
          product: @product,
          affiliate: affiliate
        )

        expect(sale.affiliate).to eq affiliate
      end

      describe "with coupon" do
        it "should include the coupon" do
          coupon = create(:payola_coupon)

          sale = CreateSale.call(
            email: 'pete@bugsplat.info',
            stripeToken: 'test_tok',
            product: @product,
            coupon: coupon
          )

          expect(sale.coupon).to eq coupon
        end
        it "should set the price correctly" do
          coupon = create(:payola_coupon)

          sale = CreateSale.call(
            email: 'pete@bugsplat.info',
            stripeToken: 'test_tok',
            product: @product,
            coupon: coupon
          )

          expect(sale.amount).to eq 99
        end
      end
    end
  end
end

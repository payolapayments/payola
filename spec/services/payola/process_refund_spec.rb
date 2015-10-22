require 'spec_helper'

module Payola
  describe ProcessRefund do
    describe "#call" do
      before :each do 
        Payola.secret_key = 'sk_test_12345'
      end

      it "should refund the sale" do
        charge = Stripe::Charge.create({
          :amount => 40,
          :currency => "usd",
          :source => StripeMock.generate_card_token({}),
        })
        
        sale = create(:sale, stripe_id: charge.id, amount: charge.amount, state: :finished)
        
        expect(Payola::Sale).to receive(:find_by).with(guid: sale.guid).and_return(sale)
        Payola::ProcessRefund.call(sale.guid)
        expect(sale.reload.refunded?).to eq(true)
      end

      it "should not refund the sale if an error occurs" do
        sale = create(:sale, stripe_id: "this doesn't exist", amount: "10", state: :finished)
        
        expect(Payola::Sale).to receive(:find_by).with(guid: sale.guid).and_return(sale)
        returned_sale = Payola::ProcessRefund.call(sale.guid)
        expect(returned_sale.errors.any?).to eq(true)
        expect(sale.reload.refunded?).to eq(false)
      end

    end
  end
end

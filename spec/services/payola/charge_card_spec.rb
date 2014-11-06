require 'spec_helper'

module Payola
  describe ChargeCard do
    describe "#call" do
      it "should create a customer" do
        sale = create(:sale, state: 'processing')
        ChargeCard.call(sale)
        expect(sale.reload.stripe_customer_id).to_not be_nil
      end
      it "should create a charge" do
        sale = create(:sale, state: 'processing')
        ChargeCard.call(sale)
        expect(sale.reload.stripe_id).to_not be_nil
        expect(sale.reload.card_last4).to_not be_nil
        expect(sale.reload.card_expiration).to_not be_nil
        expect(sale.reload.card_type).to_not be_nil
      end
      it "should get the fee from the balance transaction" do
        sale = create(:sale, state: 'processing')
        ChargeCard.call(sale)
        expect(sale.reload.fee_amount).to_not be_nil        
      end
      describe "on error" do
        it "should update the error attribute" do
          StripeMock.prepare_card_error(:card_declined)
          sale = create(:sale, state: 'processing')
          ChargeCard.call(sale)
          expect(sale.reload.error).to_not be_nil
          expect(sale.errored?).to be true
        end
      end
    end
  end
end


require 'spec_helper'

module Payola
  describe ChargeCard do
    let(:stripe_helper) { StripeMock.create_test_helper }
    describe "#call" do
      describe "on success" do
        before do
          expect(Stripe::BalanceTransaction).to receive(:retrieve).and_return(OpenStruct.new( amount: 100, fee: 3.29, currency: 'usd' ))
        end
        it "should create a customer" do
          sale = create(:sale, state: 'processing', stripe_token: stripe_helper.generate_card_token)
          ChargeCard.call(sale)
          expect(sale.reload.stripe_customer_id).to_not be_nil
        end

        it "should not create a customer if one already exists" do
          customer = Stripe::Customer.create
          sale = create(:sale, state: 'processing', stripe_customer_id: customer.id)
          expect(Stripe::Customer).to receive(:retrieve).and_return(customer)
          ChargeCard.call(sale)
          expect(sale.reload.stripe_customer_id).to eq customer.id
          expect(sale.state).to eq 'finished'
        end

        it "should create a charge" do
          sale = create(:sale, state: 'processing', stripe_token: stripe_helper.generate_card_token)
          ChargeCard.call(sale)
          expect(sale.reload.stripe_id).to_not be_nil
          expect(sale.reload.card_last4).to_not be_nil
          expect(sale.reload.card_expiration).to_not be_nil
          expect(sale.reload.card_type).to_not be_nil
        end

        it "should get the fee from the balance transaction" do
          sale = create(:sale, state: 'processing', stripe_token: stripe_helper.generate_card_token)
          ChargeCard.call(sale)
          expect(sale.reload.fee_amount).to_not be_nil        
        end
      end

      describe "on error" do
        it "should update the error attribute" do

          StripeMock.prepare_card_error(:card_declined)
          sale = create(:sale, state: 'processing', stripe_token: stripe_helper.generate_card_token)
          ChargeCard.call(sale)
          expect(sale.reload.error).to_not be_nil
          expect(sale.errored?).to be true
        end
      end
    end
  end
end


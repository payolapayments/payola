require 'spec_helper'

module Payola
  describe Sale do
    describe "validations" do
      it "should validate" do
        sale = build(:sale)
        expect(sale.valid?).to be true
      end

      it "should validate lack of email" do
        sale = build(:sale, email: nil)
        expect(sale.valid?).to be false
      end
      it "should validate product" do
        sale = build(:sale, product: nil)
        expect(sale.valid?).to be false
      end
      it "should validate stripe_token" do
        sale = build(:sale, stripe_token: nil)
        expect(sale.valid?).to be false
      end
    end

    describe "#guid" do
      it "should generate a unique guid" do
        sale = create(:sale)
        expect(sale.valid?).to be true
        expect(sale.guid).to_not be_nil

        sale2 = build(:sale, guid: sale.guid)
        expect(sale2.valid?).to be false
      end
    end

    describe "#process!" do
      it "should charge the card" do
        Payola::ChargeCard.should_receive(:call)

        sale = create(:sale)
        sale.process!
      end
    end

    describe "#finish" do
      it "should instrument finish" do
        sale = create(:sale, state: 'processing')
        Payola.should_receive(:instrument).with('payola.product.sale.finished', sale)

        sale.finish!
      end
    end

    describe "#fail" do
      it "should instrument fail" do
        sale = create(:sale, state: 'processing')
        Payola.should_receive(:instrument).with('payola.product.sale.failed', sale)

        sale.fail!
      end
    end

    describe "#refund" do
      it "should instrument refund" do
        sale = create(:sale, state: 'finished')
        Payola.should_receive(:instrument).with('payola.product.sale.refunded', sale)
        sale.refund!
      end
    end
  end
end

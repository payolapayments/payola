require 'spec_helper'

module Payola
  describe Sale do

    before do
      Payola.secret_key = 'sk_test_12345'
    end

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
        expect(Payola::ChargeCard).to receive(:call)

        sale = create(:sale)
        sale.process!
      end
    end

    describe "#finish" do
      it "should instrument finish" do
        sale = create(:sale, state: 'processing')
        expect(Payola).to receive(:instrument).with('payola.product.sale.finished', sale)
        expect(Payola).to receive(:instrument).with('payola.sale.finished', sale)

        sale.finish!
      end
    end

    describe "#fail" do
      it "should instrument fail" do
        sale = create(:sale, state: 'processing')
        expect(Payola).to receive(:instrument).with('payola.product.sale.failed', sale)
        expect(Payola).to receive(:instrument).with('payola.sale.failed', sale)

        sale.fail!
      end
    end

    describe "#refund" do
      it "should instrument refund" do
        sale = create(:sale, state: 'finished')
        expect(Payola).to receive(:instrument).with('payola.product.sale.refunded', sale)
        expect(Payola).to receive(:instrument).with('payola.sale.refunded', sale)
        sale.refund!
      end
    end

    describe "#verifier" do
      it "should store and recall verified custom fields" do
        sale = create(:sale)
        sale.signed_custom_fields = sale.verifier.generate({"field" => "value"})
        sale.save!
        sale.reload
        expect(sale.custom_fields["field"]).to eq "value"
      end
    end

    describe "#owner" do
      it "should store and recall owner" do
        sale = create(:sale)
        owner = Owner.create

        sale.owner = owner
        sale.save!

        expect(sale.owner_id).to eq owner.id
        expect(sale.owner_type).to eq 'Owner'
      end
    end
  end
end

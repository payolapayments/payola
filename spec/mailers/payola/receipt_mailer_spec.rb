require 'spec_helper'

module Payola
  describe ReceiptMailer do
    let(:sale) { create(:sale) }

    describe '#receipt' do
      it 'should send a receipt' do
        Payola.pdf_receipt = false
        mail = Payola::ReceiptMailer.receipt(sale.guid)
        expect(mail.subject).to eq 'Purchase Receipt'
      end

      it 'should send a receipt with a pdf' do
        Payola.pdf_receipt = true
        mail = Payola::ReceiptMailer.receipt(sale.guid)
        expect(mail.attachments["receipt-#{sale.guid}.pdf"]).to_not be nil
      end
    end

    describe '#refund' do
    end
  end
end

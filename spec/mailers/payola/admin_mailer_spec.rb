require 'spec_helper'

module Payola
  describe AdminMailer do
    let(:sale) { create(:sale) }

    describe '#receipt' do
      it "should send a receipt notification" do
        mail = AdminMailer.receipt(sale.guid)
        expect(mail.subject).to eq 'Receipt'
      end
    end

    describe '#refund' do
      it "should send a refund notification" do
        mail = AdminMailer.refund(sale.guid)
        expect(mail.subject).to eq 'Refund'
      end
    end

    describe '#dispute' do
      it "should send a dispute notification" do
        mail = AdminMailer.dispute(sale.guid)
        expect(mail.subject).to eq 'Dispute'
      end
    end

    describe '#failure' do
      it "should send a failure notification" do
        mail = AdminMailer.failure(sale.guid)
        expect(mail.subject).to eq 'Failure'
      end
    end
  end
end

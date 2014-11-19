require 'spec_helper'

module Payola
  describe ProcessSale do
    describe "#call" do
      it "should call process!" do
        sale = create(:sale)
        expect(Payola::Sale).to receive(:find_by).with(guid: sale.guid).and_return(sale)
        expect(sale).to receive(:process!)

        Payola::ProcessSale.call(sale.guid)
      end
    end
  end
end

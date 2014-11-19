require 'spec_helper'

module Payola
  describe ProcessSubscription do
    describe "#call" do
      it "should call process!" do
        sale = create(:sale)
        expect(Payola::Subscription).to receive(:find_by).with(guid: sale.guid).and_return(sale)
        expect(sale).to receive(:process!)

        Payola::ProcessSubscription.call(sale.guid)
      end
    end
  end
end

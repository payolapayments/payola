require 'spec_helper'

describe Payola::PriceHelper do

  describe "#price_helper" do
    it { expect(helper.formatted_price(nil)).to eq "$0.00" }
    it { expect(helper.formatted_price(0)).to eq "$0.00" }
    it { expect(helper.formatted_price(2)).to eq "$0.02" }
    it { expect(helper.formatted_price(20)).to eq "$0.20" }
    it { expect(helper.formatted_price(2000)).to eq "$20.00" }
    it { expect(helper.formatted_price(200.0)).to eq "$2.00" }

    context "options" do
      it { expect(helper.formatted_price(200, unit: '€', delimiter: ',')).to eq "€2,00" }

    end
  end
end

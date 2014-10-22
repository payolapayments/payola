module Payola
  module PriceHelper
    def formatted_price(amount, opts = {})
      number_to_currency((amount || 0) / 100.0, opts)
    end
  end
end

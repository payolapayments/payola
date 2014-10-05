class BuyController < ApplicationController
  helper Payola::PriceHelper

  def index
    @sale = Payola::Sale.new(product: Product.first)
  end
end

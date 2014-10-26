class BuyController < ApplicationController
  helper Payola::PriceHelper

  def index
    @product = Product.first
  end
end

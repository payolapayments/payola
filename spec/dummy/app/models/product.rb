class Product < ActiveRecord::Base
  include Payola::Sellable

  def redirect_path(sale)
    '/'
  end
end

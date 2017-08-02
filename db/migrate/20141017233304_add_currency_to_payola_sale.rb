class AddCurrencyToPayolaSale < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_sales, :currency, :string
  end
end

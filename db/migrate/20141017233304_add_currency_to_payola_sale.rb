class AddCurrencyToPayolaSale < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_sales, :currency, :string
  end
end

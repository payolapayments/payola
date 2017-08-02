class AddTaxPercentToPayolaSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_subscriptions, :tax_percent, :integer
  end
end

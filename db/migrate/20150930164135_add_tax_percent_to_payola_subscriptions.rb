class AddTaxPercentToPayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :tax_percent, :integer
  end
end

class ChangeTaxPercentFormatInPayolaSubscriptions < ActiveRecord::Migration[5.1]
  def up
    change_column :payola_subscriptions, :tax_percent, :decimal, :precision => 4, :scale => 2
  end

  def down
    change_column :payola_subscriptions, :tax_percent, :integer
  end
end

class ChangeTaxPercentFormatInPayolaSubscriptions < ActiveRecord::Migration
  def change
    change_column :payola_subscriptions, :tax_percent, :decimal, :precision => 4, :scale => 2
  end
end

class AddCurrencyToPayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :currency, :string
    add_column :payola_subscriptions, :amount, :integer
  end
end

class AddSetupFeeToPayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :setup_fee, :integer
  end
end

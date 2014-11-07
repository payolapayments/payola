class AddGuidToPayolaSubscriptions < ActiveRecord::Migration
  def change
    add_column :payola_subscriptions, :guid, :string
  end
end

class AddStripeIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string
  end
end

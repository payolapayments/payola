class AddStripeCustomerIdToSale < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_sales, :stripe_customer_id, :string, limit: 191
    add_index :payola_sales, :stripe_customer_id
  end
end

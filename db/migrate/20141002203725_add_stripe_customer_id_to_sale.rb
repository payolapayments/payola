class AddStripeCustomerIdToSale < ActiveRecord::Migration
  def change
    add_column :payola_sales, :stripe_customer_id, :string
    add_index :payola_sales, :stripe_customer_id
  end
end

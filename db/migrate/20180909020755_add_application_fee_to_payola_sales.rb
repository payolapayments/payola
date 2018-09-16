class AddApplicationFeeToPayolaSales < ActiveRecord::Migration
  def change
    add_column :payola_sales, :application_fee, :integer
  end
end

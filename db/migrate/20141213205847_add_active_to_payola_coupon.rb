class AddActiveToPayolaCoupon < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_coupons, :active, :boolean, default: true
  end
end

class AddActiveToPayolaCoupon < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_coupons, :active, :boolean, default: true
  end
end

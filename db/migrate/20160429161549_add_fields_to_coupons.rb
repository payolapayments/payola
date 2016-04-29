class AddFieldsToCoupons < ActiveRecord::Migration
  def change
    add_column :payola_coupons, :amount_off, :integer, default: true
    add_column :payola_coupons, :duration, :string, default: 'once'
    add_column :payola_coupons, :duration_in_months, :integer
    add_column :payola_coupons, :max_redemptions, :integer
    add_column :payola_coupons, :redeem_by, :timestamp
    add_column :payola_coupons, :currency, :string
  end
end

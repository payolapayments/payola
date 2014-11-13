class CreateAppCoupons < ActiveRecord::Migration
  def change
    create_table :app_coupons do |t|
      t.integer :percent_off
      t.integer :amount_off
      t.string :currency
      t.string :duration
      t.integer :duration_in_months
      t.string :stripe_id
      t.integer :max_redemptions
      t.timestamp :redeem_by

      t.timestamps
    end
  end
end

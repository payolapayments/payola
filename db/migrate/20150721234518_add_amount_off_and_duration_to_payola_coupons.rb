class AddAmountOffAndDurationToPayolaCoupons < ActiveRecord::Migration
  def change
    add_column :payola_coupons, :amount_off, :integer
    add_column :payola_coupons, :duration, :string
  end
end

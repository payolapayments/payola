class AddDurationInMonthsToPayolaCoupons < ActiveRecord::Migration
  def change
    add_column :payola_coupons, :duration_in_months, :integer
  end
end

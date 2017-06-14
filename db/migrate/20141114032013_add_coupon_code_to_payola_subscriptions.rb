class AddCouponCodeToPayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :coupon, :string
  end
end

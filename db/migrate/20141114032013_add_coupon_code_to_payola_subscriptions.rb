class AddCouponCodeToPayolaSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_subscriptions, :coupon, :string
  end
end

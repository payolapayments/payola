class AddAffiliateIdToPayolaSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_subscriptions, :affiliate_id, :integer
  end
end

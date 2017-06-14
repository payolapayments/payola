class AddAffiliateIdToPayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :affiliate_id, :integer
  end
end

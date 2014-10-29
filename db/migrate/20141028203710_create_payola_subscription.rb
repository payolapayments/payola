class CreatePayolaSubscription < ActiveRecord::Migration
  def change
    create_table :payola_subscriptions do |t|
      t.string  "email"
      t.string  "guid"
      t.integer "plan_id"
      t.integer "plan_type"
      t.integer "subscribable_id"
      t.integer "subscribable_type"
      t.string  "state"
      t.string  "stripe_id"
      t.integer "affiliate_id"
      t.text    "error"
      t.timestamps
    end

    add_index :payola_subscriptions, :guid
    add_index :payola_subscriptions, :stripe_id
  end
end

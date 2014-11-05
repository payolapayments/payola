class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.integer :amount
      t.string :interval
      t.integer :interval_count
      t.string :name
      t.string :stripe_id
      t.integer :trial_period_days

      t.timestamps
    end
  end
end

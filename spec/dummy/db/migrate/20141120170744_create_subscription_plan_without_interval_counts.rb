class CreateSubscriptionPlanWithoutIntervalCounts < ActiveRecord::Migration
  def change
    create_table :subscription_plan_without_interval_counts do |t|
      t.string :name
      t.string :stripe_id
      t.integer :amount
      t.string :interval

      t.timestamps
    end
  end
end

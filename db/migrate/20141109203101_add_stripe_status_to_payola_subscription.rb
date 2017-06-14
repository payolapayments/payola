class AddStripeStatusToPayolaSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :stripe_status, :string
  end
end

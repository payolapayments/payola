class AddStripeStatusToPayolaSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_subscriptions, :stripe_status, :string
  end
end

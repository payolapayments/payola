class AddSignedCustomFieldsToPayolaSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_subscriptions, :signed_custom_fields, :text
  end
end

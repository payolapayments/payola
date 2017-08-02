class AddSignedCustomFieldsToPayolaSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :payola_subscriptions, :signed_custom_fields, :text
  end
end

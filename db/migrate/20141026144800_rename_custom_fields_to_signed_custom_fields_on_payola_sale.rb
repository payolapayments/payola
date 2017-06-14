class RenameCustomFieldsToSignedCustomFieldsOnPayolaSale < ActiveRecord::Migration[4.2]
  def change
    rename_column :payola_sales, :custom_fields, :signed_custom_fields
  end
end

class AddCustomFieldsToPayolaSale < ActiveRecord::Migration[4.2]
  def change
    add_column :payola_sales, :custom_fields, :text
  end
end

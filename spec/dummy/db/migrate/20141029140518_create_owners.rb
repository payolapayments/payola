class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|

      t.timestamps
    end
  end
end

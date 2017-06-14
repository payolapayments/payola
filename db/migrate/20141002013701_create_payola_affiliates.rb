class CreatePayolaAffiliates < ActiveRecord::Migration[4.2]
  def change
    create_table :payola_affiliates do |t|
      t.string :code
      t.string :email
      t.integer :percent

      t.timestamps
    end
  end
end

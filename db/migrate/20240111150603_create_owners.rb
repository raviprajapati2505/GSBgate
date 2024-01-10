class CreateOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :owners do |t|
      t.string :name, null: false
      t.boolean :governmental
      t.boolean :private_developer
      t.boolean :private_owner

      t.timestamps
    end
  end
end

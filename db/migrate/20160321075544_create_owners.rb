class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name, null: false
      t.boolean :governmental
      t.boolean :private_developer
      t.boolean :private_owner
    end

    remove_column :projects, :owner_id
    add_column :projects, :owner, :string, null: false, default: 'VITO'
  end
end

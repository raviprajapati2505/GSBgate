class AddNameToSchemeMixes < ActiveRecord::Migration[4.2]
  def up
    add_column :scheme_mixes, :name, :string
  end

  def down
    remove_column :scheme_mixes, :name
  end
end

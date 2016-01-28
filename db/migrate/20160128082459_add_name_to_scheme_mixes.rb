class AddNameToSchemeMixes < ActiveRecord::Migration
  def up
    add_column :scheme_mixes, :name, :string
  end

  def down
    remove_column :scheme_mixes, :name
  end
end

class RenameNameInSchemeMix < ActiveRecord::Migration[4.2]
  def up
    rename_column :scheme_mixes, :name, :custom_name
    add_index :scheme_mixes, [:custom_name, :scheme_id], unique: true, name: 'ui_custom_name_scheme'
  end

  def down
    rename_column :scheme_mixes, :custom_name, :name
    remove_index :scheme_mixes, 'ui_custom_name_scheme'
  end
end

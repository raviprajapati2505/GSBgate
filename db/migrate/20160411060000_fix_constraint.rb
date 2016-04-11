class FixConstraint < ActiveRecord::Migration
  def up
    remove_index :scheme_mixes, name: 'ui_custom_name_scheme'
    add_index :scheme_mixes, [:certification_path_id, :scheme_id, :custom_name], unique: true, name: 'ui_custom_name_scheme'
  end

  def down
    remove_index :scheme_mixes, name: 'ui_custom_name_scheme'
    add_index :scheme_mixes, [:custom_name, :scheme_id], unique: true, name: 'ui_custom_name_scheme'
  end
end

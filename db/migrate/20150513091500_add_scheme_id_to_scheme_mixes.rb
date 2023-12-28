class AddSchemeIdToSchemeMixes < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mixes, :scheme_id, :integer, :references => 'schemes'
  end
end

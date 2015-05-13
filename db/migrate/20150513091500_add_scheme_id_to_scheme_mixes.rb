class AddSchemeIdToSchemeMixes < ActiveRecord::Migration
  def change
    add_column :scheme_mixes, :scheme_id, :integer, :references => 'schemes'
  end
end

class AddSubSchemesToOfflineSchemeMixesTable < ActiveRecord::Migration[5.2]
  def change
    add_column :offline_scheme_mixes, :subschemes, :string
  end
end

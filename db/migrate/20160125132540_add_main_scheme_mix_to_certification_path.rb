class AddMainSchemeMixToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_reference :certification_paths, :main_scheme_mix, references: :scheme_mixes, index: true
    add_foreign_key :certification_paths, :scheme_mixes, column: :main_scheme_mix_id
    add_column :certification_paths, :main_scheme_mix_selected, :boolean, null: false, default: false
  end
end

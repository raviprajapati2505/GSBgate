class CreateSchemeMixes < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mixes do |t|
      t.references :certification_path, foreign_key: true, index: true
      t.string :custom_name
      t.integer :scheme_id
      t.integer :weight, limit: 3

      t.timestamps null: false
    end

    add_reference :certification_paths, :main_scheme_mix, references: :scheme_mixes, index: true
    add_foreign_key :certification_paths, :scheme_mixes, column: :main_scheme_mix_id
    add_index :scheme_mixes, [:certification_path_id, :scheme_id, :custom_name], unique: true, name: 'ui_custom_name_scheme'
  end
end

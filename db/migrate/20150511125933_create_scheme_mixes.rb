class CreateSchemeMixes < ActiveRecord::Migration[4.2]
  def change
    create_table :scheme_mixes do |t|
      t.references :certification_path, index: true, foreign_key: true
      t.integer :weight, limit: 3
      t.timestamps null: false
    end
  end
end

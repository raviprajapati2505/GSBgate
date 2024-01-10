class CreateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.references :calculator, foreign_key: true, index: true
      t.string :machine_name
      t.string :name
      t.string :datum_type
      t.string :validation
      t.string :prefix
      t.string :suffix
      t.boolean :required
      t.text :help_text

      t.timestamps null: false
    end
  end
end

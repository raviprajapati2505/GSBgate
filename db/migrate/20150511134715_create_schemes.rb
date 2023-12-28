class CreateSchemes < ActiveRecord::Migration[4.2]
  def change
    create_table :schemes do |t|
      t.string :label
      t.references :certificate, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

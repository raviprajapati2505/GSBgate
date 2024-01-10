class CreateDistricts < ActiveRecord::Migration[7.0]
  def change
    create_table :districts do |t|
      t.text :list, default: [], array: true
      t.string :country
      t.string :city

      t.timestamps
    end
  end
end

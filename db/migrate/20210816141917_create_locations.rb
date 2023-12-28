class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :country
      t.text :list, default: [], array: true

      t.timestamps
    end
  end
end

class CreateDistricts < ActiveRecord::Migration[5.2]
  def up
    drop_table :districts if table_exists?(:districts)
    
    create_table :districts do |t|
      t.text :list, default: [], array: true
      t.string :country
      t.string :city

      t.timestamps
    end
  end

  def down
    drop_table :districts
  end
end

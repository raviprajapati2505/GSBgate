class AddForeignKeyToSchemeMix < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key "scheme_mixes", "schemes"
  end
end

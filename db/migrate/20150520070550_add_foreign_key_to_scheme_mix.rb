class AddForeignKeyToSchemeMix < ActiveRecord::Migration
  def change
    add_foreign_key "scheme_mixes", "schemes"
  end
end

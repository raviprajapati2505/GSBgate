class RenameFieldTypeToDatumType < ActiveRecord::Migration
  def change
    rename_column :fields, :type, :datum_type
  end
end


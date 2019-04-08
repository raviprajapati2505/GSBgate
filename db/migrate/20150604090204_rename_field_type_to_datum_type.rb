class RenameFieldTypeToDatumType < ActiveRecord::Migration[4.2]
  def change
    rename_column :fields, :type, :datum_type
  end
end


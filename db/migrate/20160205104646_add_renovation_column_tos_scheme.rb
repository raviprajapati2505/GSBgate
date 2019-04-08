class AddRenovationColumnTosScheme < ActiveRecord::Migration[4.2]
  def up
    add_column :schemes, :renovation, :boolean, null: false, default: false
  end

  def down
    remove_column :schemes, :renovation
  end
end

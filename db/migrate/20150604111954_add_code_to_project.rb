class AddCodeToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :code, :string
  end
end

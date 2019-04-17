class AddDeveloperToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :developer, :string
  end
end

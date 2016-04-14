class AddDeveloperToProject < ActiveRecord::Migration
  def change
    add_column :projects, :developer, :string
  end
end

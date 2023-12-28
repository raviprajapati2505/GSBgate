class AddSpecifyOtherToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :specify_other_project_use, :string
  end
end

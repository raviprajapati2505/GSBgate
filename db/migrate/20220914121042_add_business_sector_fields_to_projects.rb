class AddBusinessSectorFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :project_owner_business_sector, :integer
    add_column :projects, :project_developer_business_sector, :integer
  end
end

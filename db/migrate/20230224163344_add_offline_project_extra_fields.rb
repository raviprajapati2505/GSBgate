class AddOfflineProjectExtraFields < ActiveRecord::Migration[5.2]
  def change
    add_column :offline_projects, :project_country, :string
    add_column :offline_projects, :project_city, :string
    add_column :offline_projects, :project_district, :string
    add_column :offline_projects, :project_owner_business_sector, :string
    add_column :offline_projects, :project_developer_business_sector, :string
    add_column :offline_projects, :project_gross_built_up_area, :string
  end
end

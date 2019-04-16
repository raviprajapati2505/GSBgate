class AddExtraProjectFields < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :certificate_type, :integer
    # add second service provider for LOC/Final Design projects
    add_column :projects, :service_provider_2, :string
    # for all building type groups
    add_column :projects, :estimated_project_cost, :string
    add_column :projects, :cost_square_meter, :string
    # for district and infrastructure building type group
    add_column :projects, :estimated_building_cost, :string
    add_column :projects, :estimated_infrastructure_cost, :string
  end

  def down
    remove_column :projects, :certificate_type
    remove_column :projects, :service_provider_2
    remove_column :projects, :estimated_project_cost
    remove_column :projects, :cost_square_meter
    remove_column :projects, :estimated_building_cost
    remove_column :projects, :estimated_infrastructure_cost
  end
end

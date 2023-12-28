class AddBuildingsFootprintAreaToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :buildings_footprint_area, :integer
  end
end

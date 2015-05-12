class RenameAndAddProjectBaseFields < ActiveRecord::Migration
  def change
    remove_column :projects, :country
    remove_column :projects, :city
    remove_column :projects, :street
    remove_column :projects, :number
    remove_column :projects, :project_status_id

    add_column :projects, :address, :text
    add_column :projects, :location, :string
    add_column :projects, :country, :string
    add_column :projects, :latlng,  :st_point, geographic: true
    add_column :projects, :gross_area, :integer
    add_column :projects, :certified_area, :integer
    add_column :projects, :carpark_area, :integer
    add_column :projects, :project_site_area, :integer
  end
end

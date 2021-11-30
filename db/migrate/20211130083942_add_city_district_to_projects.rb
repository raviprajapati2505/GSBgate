class AddCityDistrictToProjects < ActiveRecord::Migration[5.2]
  def up
    add_column :projects, :city, :string
    add_column :projects, :district, :string

    Project.all.each do |project|
      project.city = project&.location
      project.save(validate: false)
    end
  end

  def down
    remove_column :projects, :city
    remove_column :projects, :district
  end
end

class ConvertProjectsLatlngToNonPostgisColumnCoordinates < ActiveRecord::Migration
  def change
    add_column :projects, :coordinates, :string

    # Copy data from latlng field (PostGIS geography) to coordinates field (varchar)
    Project.all.each do |project|
      # Convert format "POINT (lng lat)" to "lat,lng"
      coordinates = project.latlng.to_s.sub('POINT (', '').sub(')', '').strip.split(' ').reverse.join(',')

      # Save the data to the new coordinates field
      project.update_column(:coordinates, coordinates)
    end
  end
end

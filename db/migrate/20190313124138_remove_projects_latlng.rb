class RemoveProjectsLatlng < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :latlng
  end
end

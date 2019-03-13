class RemoveProjectsLatlng < ActiveRecord::Migration
  def change
    remove_column :projects, :latlng
  end
end

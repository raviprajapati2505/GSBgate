class DestroyAllOrphanTasks < ActiveRecord::Migration
  def change
    Task.joins(:certification_path).delete_all(certification_paths: {certification_path_status_id: [15,16]})
  end
end

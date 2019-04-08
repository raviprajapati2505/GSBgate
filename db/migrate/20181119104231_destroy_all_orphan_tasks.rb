class DestroyAllOrphanTasks < ActiveRecord::Migration[4.2]
  def change
    Task.joins(:certification_path).where(certification_paths: {certification_path_status_id: [15,16]}).delete_all
  end
end

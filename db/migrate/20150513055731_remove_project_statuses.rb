class RemoveProjectStatuses < ActiveRecord::Migration[4.2]
  def change
    drop_table :project_statuses
  end
end

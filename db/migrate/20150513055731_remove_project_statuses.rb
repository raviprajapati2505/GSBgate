class RemoveProjectStatuses < ActiveRecord::Migration
  def change
    drop_table :project_statuses
  end
end

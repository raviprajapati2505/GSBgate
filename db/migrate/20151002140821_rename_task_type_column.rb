class RenameTaskTypeColumn < ActiveRecord::Migration
  def change
    rename_column :tasks, :task_type, :type
  end
end

class RenameTaskTypeColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :tasks, :task_type, :type
  end
end

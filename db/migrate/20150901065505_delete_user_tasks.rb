class DeleteUserTasks < ActiveRecord::Migration[4.2]
  def change
    drop_table :user_tasks
  end
end

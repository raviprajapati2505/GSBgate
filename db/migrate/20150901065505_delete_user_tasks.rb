class DeleteUserTasks < ActiveRecord::Migration
  def change
    drop_table :user_tasks
  end
end

class AddProjectToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_reference :notifications, :project, references: :projects, index: true
  end
end

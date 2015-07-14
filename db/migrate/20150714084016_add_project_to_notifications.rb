class AddProjectToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :project, references: :projects, index: true
  end
end

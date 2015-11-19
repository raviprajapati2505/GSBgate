class AddProjectIdToNotificationTypesUsers < ActiveRecord::Migration
  def change
    add_reference :notification_types_users, :project, index: true, foreign_key: true
    add_column :notification_types, :project_level, :boolean

    NotificationType.all.each do |notification_type|
      if notification_type.id == NotificationType::PROJECT_CREATED || notification_type.id == NotificationType::NEW_TASK
        notification_type.project_level = false
      else
        notification_type.project_level = true
      end
      notification_type.save!
    end
  end
end

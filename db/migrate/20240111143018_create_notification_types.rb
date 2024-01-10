class CreateNotificationTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_types do |t|
      t.string :name
      t.boolean :project_level

      t.timestamps null: false
    end
  end
end

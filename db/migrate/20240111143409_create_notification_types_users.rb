class CreateNotificationTypesUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_types_users do |t|
      t.references :notification_type, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.references :project, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end

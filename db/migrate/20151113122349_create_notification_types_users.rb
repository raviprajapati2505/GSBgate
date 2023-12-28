class CreateNotificationTypesUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :notification_types_users do |t|
      t.references :notification_type, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

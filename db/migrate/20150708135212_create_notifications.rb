class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.text :body
      t.boolean :read
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

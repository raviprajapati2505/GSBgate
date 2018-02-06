class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.string :archive_file
      t.integer :status
      t.references :subject, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

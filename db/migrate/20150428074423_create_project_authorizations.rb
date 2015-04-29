class CreateProjectAuthorizations < ActiveRecord::Migration
  def change
    create_table :project_authorizations do |t|
      t.references :user, index: true, foreign_key: true
      t.belongs_to :project, index: true, foreign_key: true
      t.string :category
      # project managers can give other users read/write/manager authorization to the project
      t.boolean :project_manager
      t.boolean :write_access

      t.timestamps null: false
    end
  end
end

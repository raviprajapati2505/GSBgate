class ChangePermissionLevel < ActiveRecord::Migration[4.2]
  def change
    add_reference :project_authorizations, :requirement_datum, index: true, foreign_key: true
    remove_reference :project_authorizations, :category
    add_reference :projects, :client, references: :users
    add_reference :projects, :owner, references: :users
    remove_reference :projects, :user
  end
end

class AddProjectOwnerEmailToProjectsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :project_owner_email, :string
  end
end

class AddProjectBaseFields < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :description, :text
    add_column :projects, :project_status_id, :integer, :references => 'project_statuses'
    add_column :projects, :country, :string
    add_column :projects, :city, :string
    add_column :projects, :street, :string
    add_column :projects, :number, :string
  end
end

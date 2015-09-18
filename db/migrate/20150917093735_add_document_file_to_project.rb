class AddDocumentFileToProject < ActiveRecord::Migration
  def change
    add_column :projects, :location_plan_file, :string
    add_column :projects, :site_plan_file, :string
    add_column :projects, :design_brief_file, :string
    add_column :projects, :project_narrative_file, :string
  end
end

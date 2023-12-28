class AddSlugToProjectsSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_surveys, :slug, :string
    add_index :projects_surveys, :slug, unique: true
  end
end

class AddCategoryToProjectAuthorization < ActiveRecord::Migration[4.2]
  def change
    remove_column :project_authorizations, :category
    add_reference :project_authorizations, :category, index: true, foreign_key: true
  end
end

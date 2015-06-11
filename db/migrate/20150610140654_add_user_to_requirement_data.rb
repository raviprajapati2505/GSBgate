class AddUserToRequirementData < ActiveRecord::Migration
  def change
    add_reference :requirement_data, :user, index: true, foreign_key: true

    remove_reference :project_authorizations, :requirement_datum, index: true, foreign_key: true
    remove_column :project_authorizations, :permission, :integer
  end
end

class AddRequirementDataRequirementRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :requirement_data, :requirement_id, :integer, :references => 'requirements'
  end
end

class AddRequirementDataRequirementRelationship < ActiveRecord::Migration
  def change
    add_column :requirement_data, :requirement_id, :integer, :references => 'requirements'
  end
end

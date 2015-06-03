class AddStatusToRequirementData < ActiveRecord::Migration
  def change
    add_column :requirement_data, :status, :integer
  end
end

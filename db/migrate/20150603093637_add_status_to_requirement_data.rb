class AddStatusToRequirementData < ActiveRecord::Migration[4.2]
  def change
    add_column :requirement_data, :status, :integer
  end
end

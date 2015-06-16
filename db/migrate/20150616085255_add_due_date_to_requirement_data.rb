class AddDueDateToRequirementData < ActiveRecord::Migration
  def change
    add_column :requirement_data, :due_date, :date
  end
end

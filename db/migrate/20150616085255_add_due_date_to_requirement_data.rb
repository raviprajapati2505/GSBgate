class AddDueDateToRequirementData < ActiveRecord::Migration[4.2]
  def change
    add_column :requirement_data, :due_date, :date
  end
end

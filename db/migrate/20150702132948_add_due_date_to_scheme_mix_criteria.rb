class AddDueDateToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :due_date, :date
  end
end

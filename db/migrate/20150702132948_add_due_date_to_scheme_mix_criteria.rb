class AddDueDateToSchemeMixCriteria < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :due_date, :date
  end
end

class AddApprovedDateToSchemeMixCriteriaDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :scheme_mix_criteria_documents, :approved_date, :datetime
  end
end

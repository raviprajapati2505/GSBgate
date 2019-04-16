class AddStatusToSchemeMixCriteriaDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria_documents, :status, :integer
  end
end

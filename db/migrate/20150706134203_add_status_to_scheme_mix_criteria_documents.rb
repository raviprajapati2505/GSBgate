class AddStatusToSchemeMixCriteriaDocuments < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria_documents, :status, :integer
  end
end

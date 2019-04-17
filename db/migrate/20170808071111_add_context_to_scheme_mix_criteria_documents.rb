class AddContextToSchemeMixCriteriaDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria_documents, :pcr_context, :string
  end
end

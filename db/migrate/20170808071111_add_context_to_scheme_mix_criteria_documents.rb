class AddContextToSchemeMixCriteriaDocuments < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria_documents, :pcr_context, :string
  end
end

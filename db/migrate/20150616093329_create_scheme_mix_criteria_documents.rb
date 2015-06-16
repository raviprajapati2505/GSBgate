class CreateSchemeMixCriteriaDocuments < ActiveRecord::Migration
  def change
    create_table :scheme_mix_criteria_documents do |t|
      t.references :scheme_mix_criterion, index: true, foreign_key: true
      t.references :document, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index(:scheme_mix_criteria_documents, [:scheme_mix_criterion_id, :document_id], unique: true, name: 'scheme_mix_criteria_documents_unique')
  end
end

class CreateSchemeMixCriteriaDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criteria_documents do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: true
      t.references :document, foreign_key: true, index: true
      t.integer :status
      t.integer :document_type, default: 0
      t.string :pcr_context
      t.datetime :approved_date

      t.timestamps null: false
    end

    add_index(:scheme_mix_criteria_documents, [:scheme_mix_criterion_id, :document_id], unique: true, name: 'scheme_mix_criteria_documents_unique')
  end
end

class CreateSchemeMixCriteriaDocumentComments < ActiveRecord::Migration[4.2]
  def change
    create_table :scheme_mix_criteria_document_comments do |t|
      t.text :body
      t.references :scheme_mix_criteria_document, index: { name: 'index_scheme_mix_criteria_document_comments' }, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

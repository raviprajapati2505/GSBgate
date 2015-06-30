class CreateDocumentComments < ActiveRecord::Migration
  def change
    create_table :document_comments do |t|
      t.text :body
      t.references :document, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

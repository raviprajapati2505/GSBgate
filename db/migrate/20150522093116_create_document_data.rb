class CreateDocumentData < ActiveRecord::Migration[4.2]
  def change
    create_table :document_data do |t|
      t.references :document, index: true, foreign_key: true

      t.string :file_path

      t.timestamps null: false
    end
  end
end

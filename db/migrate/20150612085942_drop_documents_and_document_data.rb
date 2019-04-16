class DropDocumentsAndDocumentData < ActiveRecord::Migration[4.2]
  def change
    rename_column :requirements, :reportable_id, :calculator_id
    rename_column :requirement_data, :reportable_data_id, :calculator_datum_id
    remove_column :requirements, :reportable_type
    remove_column :requirement_data, :reportable_data_type
    drop_table :document_data
    drop_table :documents
  end
end

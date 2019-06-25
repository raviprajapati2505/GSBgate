class AddCriterionDocumnetIdsToArchive < ActiveRecord::Migration[5.2]
  def change
    add_column :archives, :criterion_document_ids, :text, array: true, default: []
    add_column :archives, :all_criterion_document, :boolean, default: false 
  end
end

class DropDocumentComments < ActiveRecord::Migration[4.2]
  def change
    drop_table :document_comments
  end
end

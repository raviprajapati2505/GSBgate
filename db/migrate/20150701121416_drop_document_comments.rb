class DropDocumentComments < ActiveRecord::Migration
  def change
    drop_table :document_comments
  end
end

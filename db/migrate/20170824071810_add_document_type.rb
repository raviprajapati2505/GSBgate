class AddDocumentType < ActiveRecord::Migration
  def change
    BaseDocument.where(type: nil).update_all(type: 'Document')
  end
end

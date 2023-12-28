class AddDocumentType < ActiveRecord::Migration[4.2]
  def change
    BaseDocument.where(type: nil).update_all(type: 'Document')
  end
end

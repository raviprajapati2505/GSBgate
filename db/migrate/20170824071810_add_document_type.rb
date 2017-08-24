class AddDocumentType < ActiveRecord::Migration
  def change
    documents = Document.where(type: nil)
    documents.each do |document|
      document.type = 'Document'
      document.save!
    end
  end
end

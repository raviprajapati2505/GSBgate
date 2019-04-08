class AddStoreDirToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :store_dir, :text
  end
end

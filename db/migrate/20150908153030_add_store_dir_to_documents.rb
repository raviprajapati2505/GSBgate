class AddStoreDirToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :store_dir, :text
  end
end

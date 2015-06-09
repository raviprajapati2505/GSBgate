class RemoveLabelFromDocument < ActiveRecord::Migration
  def change
    remove_column :documents, :label
  end
end

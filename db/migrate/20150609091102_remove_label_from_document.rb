class RemoveLabelFromDocument < ActiveRecord::Migration[4.2]
  def change
    remove_column :documents, :label
  end
end

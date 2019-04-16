class RemoveCategoryWeight < ActiveRecord::Migration[4.2]
  def change
    remove_column :categories, :weight
  end
end

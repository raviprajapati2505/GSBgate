class RemoveCategoryWeight < ActiveRecord::Migration
  def change
    remove_column :categories, :weight
  end
end

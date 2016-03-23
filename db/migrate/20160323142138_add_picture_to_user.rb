class AddPictureToUser < ActiveRecord::Migration
  def up
    add_column :users, :picture, :text
  end

  def down
    remove_column :users, :picture
  end
end

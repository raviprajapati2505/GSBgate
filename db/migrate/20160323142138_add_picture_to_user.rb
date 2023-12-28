class AddPictureToUser < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :picture, :text
  end

  def down
    remove_column :users, :picture
  end
end

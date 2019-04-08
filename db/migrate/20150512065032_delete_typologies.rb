class DeleteTypologies < ActiveRecord::Migration[4.2]
  def change
    drop_table :typologies
  end
end

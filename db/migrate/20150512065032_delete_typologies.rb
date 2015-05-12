class DeleteTypologies < ActiveRecord::Migration
  def change
    drop_table :typologies
  end
end

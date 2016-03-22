class AddLinkmeFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :linkme_member_id, :string
    add_column :users, :username, :string, null: false
    add_column :users, :linkme_user, :boolean, null: false, default: true

    add_index :users, :linkme_member_id, unique: true
    add_index :users, :username, unique: true
  end
end

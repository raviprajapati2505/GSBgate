class ChangeConstraintOnUsername < ActiveRecord::Migration
  def change
    # Instead of "username" begin unique, the combination of "linkme_member_id" and "username" should now be unique.
    # This was changed because some Linkme users move their username to another account.
    remove_index "users", name: 'index_users_on_username'
    add_index "users", ['username', 'linkme_member_id'], name: 'index_users_on_username_and_linkme_member_id', unique: true, using: :btree
  end
end

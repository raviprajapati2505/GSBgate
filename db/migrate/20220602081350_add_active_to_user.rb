class AddActiveToUser < ActiveRecord::Migration[5.2]
  def up
    unless column_exists? :users, :active
      add_column :users, :active, :boolean, default: false
    end

    # confirm existing users.
    User.update_all(confirmed_at: Time.now, active: true)
  end

  def down
    if column_exists? :users, :active
      remove_column :users, :active
    end
  end
end

class AddLastNotifiedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_notified_at, :datetime
  end
end

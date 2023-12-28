class AddUriToNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :uri, :string, limit: 2048
  end
end

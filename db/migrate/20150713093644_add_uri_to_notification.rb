class AddUriToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :uri, :string, limit: 2048
  end
end

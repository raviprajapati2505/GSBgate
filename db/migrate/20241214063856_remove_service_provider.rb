# Removing the Service provider model and its association with the user and project model
class RemoveServiceProvider < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :type # remove STI column
    remove_column :users, :service_provider_id
    remove_column :projects, :service_provider
    remove_column :projects, :service_provider_2
    drop_table :service_provider_details
  end
end

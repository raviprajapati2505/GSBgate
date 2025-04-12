class RenameServiceProviderToCorporate < ActiveRecord::Migration[7.0]
  def up
    # Rename service_provider to corporate in Schema
    rename_column :projects, :service_provider, :corporate
    rename_column :projects, :service_provider_2, :corporate_2

    rename_column :service_provider_details, :service_provider_id, :corporate_id
    rename_column :service_provider_details, :accredited_service_provider_licence_file, :accredited_corporate_licence_file
    rename_table :service_provider_details, :corporate_details

    if column_exists?(:user_details, :accredited_service_provider_licence_file)
      rename_column :user_details, :accredited_service_provider_licence_file, :accredited_corporate_licence_file
    end

    rename_column :users, :service_provider_id, :corporate_id
  end

  def down
  end
end

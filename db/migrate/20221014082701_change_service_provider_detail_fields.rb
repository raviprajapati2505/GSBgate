class ChangeServiceProviderDetailFields < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization_email, :string
    add_column :service_provider_details, :cgp_licence_file, :string
    add_column :service_provider_details, :gsas_energey_assessment_licence_file, :string
    add_column :service_provider_details, :energy_assessor_name, :string
  end
end

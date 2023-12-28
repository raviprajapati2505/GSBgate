class AddServiceProvideToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :service_provider_id, :integer, null: true, index: true
    add_foreign_key :users, :users, column: :service_provider_id

    add_column :users, :cgp_license_expiry_date, :datetime
    add_column :users, :cep_license, :boolean, default: false
    add_column :users, :cep_license_expired, :boolean, default: false
    add_column :users, :cep_license_expiry_date, :datetime
  end
end

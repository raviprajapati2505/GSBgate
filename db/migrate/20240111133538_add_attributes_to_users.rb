class AddAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string
    add_column :users, :gord_employee, :boolean, null: false, default: false
    add_column :users, :last_notified_at, :datetime
    add_column :users, :organization_name, :string
    add_column :users, :service_provider_id, :integer, null: true, index: true
    add_column :users, :name_suffix, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :email_alternate, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :mobile_area_code, :string
    add_column :users, :mobile, :string
    add_column :users, :organization_address, :string
    add_column :users, :organization_country, :string
    add_column :users, :organization_city, :string
    add_column :users, :organization_website, :string
    add_column :users, :organization_phone_area_code, :string
    add_column :users, :organization_phone, :string
    add_column :users, :organization_fax_area_code, :string
    add_column :users, :organization_fax, :string
    add_column :users, :gsas_id, :string
    add_column :users, :approved_at, :datetime
    add_column :users, :active, :boolean, default: false
    add_column :users, :practitioner_accreditation_type, :integer
    add_column :users, :otp, :integer
    add_column :users, :organization_email, :string
    add_column :users, :profile_pic, :string

    add_foreign_key :users, :users, column: :service_provider_id

    add_index :users, :confirmation_token, unique: true
    add_index :users, :username, unique: true
  end
end

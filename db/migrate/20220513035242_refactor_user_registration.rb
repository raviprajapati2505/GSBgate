class RefactorUserRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name_suffix, :string
    add_column :users, :gender, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :dob, :date
    add_column :users, :email_alternate, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :mobile_area_code, :string
    add_column :users, :mobile, :string
    add_column :users, :designation, :string
    add_column :users, :work_experience, :integer
    add_column :users, :organization_address, :string
    add_column :users, :organization_country, :string
    add_column :users, :organization_city, :string
    add_column :users, :organization_website, :string
    add_column :users, :organization_phone_area_code, :string
    add_column :users, :organization_phone, :string
    add_column :users, :organization_fax_area_code, :string
    add_column :users, :organization_fax, :string
    add_column :users, :gsas_id, :string
    add_column :users, :qid_or_passport_number, :string
    add_column :users, :approved_at, :datetime

    remove_column :users, :linkme_member_id
    remove_column :users, :linkme_user
    remove_column :users, :cgp_license
    remove_column :users, :cgp_license_expired
    remove_column :users, :cgp_license_expiry_date
    remove_column :users, :cep_license
    remove_column :users, :cep_license_expired
    remove_column :users, :cep_license_expiry_date
    remove_column :users, :picture

    rename_column :users, :employer_name, :organization_name
  end
end

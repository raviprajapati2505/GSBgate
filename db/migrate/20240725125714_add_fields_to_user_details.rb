class AddFieldsToUserDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :user_details, :business_field, :string
    add_column :user_details, :portfolio, :string
    add_column :user_details, :commercial_licence_no, :string
    add_column :user_details, :commercial_licence_file, :string
    add_column :user_details, :commercial_licence_expiry_date, :date
    add_column :user_details, :accredited_service_provider_licence_file, :string
    add_column :user_details, :demerit_acknowledgement_file, :string
    add_column :user_details, :application_form, :string
    add_column :user_details, :nominated_cgp, :string
    add_column :user_details, :exam, :string
    add_column :user_details, :workshop, :string
  end
end

class AddOtherDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :practitioner_accreditation_type, :integer
    add_column :user_details, :education, :integer
    add_column :user_details, :education_certificate, :string
    add_column :user_details, :other_documents, :string
    add_column :service_provider_details, :application_form, :string
  end
end

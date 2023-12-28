class RefactorUserRegistraitonVersion2 < ActiveRecord::Migration[5.2]
  def up
    create_table :user_details do |t|
      t.references :user, index: true, foreign_key: true
      t.date :dob
      t.string :designation
      t.string :work_experience
      t.string :qid_or_passport_number
      t.string :gender
      t.string :qid_file
      t.string :university_credentials_file
      t.string :work_experience_file
      t.string :cgp_licence_file
      t.string :qid_work_permit_file
      t.string :gsas_energey_assessment_licence_file
      t.string :energy_assessor_name
      t.timestamps
    end

    create_table :service_provider_details do |t|
      t.references :service_provider, foreign_key: {to_table: :users}
      t.string :business_field
      t.string :portfolio
      t.string :commercial_licence_no
      t.string :commercial_licence_file
      t.date :commercial_licence_expiry_date
      t.string :accredited_service_provider_licence_file
      t.string :demerit_acknowledgement_file
      t.timestamps
    end
    # remove_column :users, :dob
    # remove_column :users, :designation
    # remove_column :users, :work_experience
    # remove_column :users, :qid_or_passport_number
    # remove_column :users, :gender
  end

  def down
    drop_table :user_details
    drop_table :service_provider_details
  end
end

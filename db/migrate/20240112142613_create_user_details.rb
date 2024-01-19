class CreateUserDetails < ActiveRecord::Migration[7.0]
  def change
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
      t.string :gsb_energey_assessment_licence_file
      t.string :energy_assessor_name
      t.integer :education
      t.string :education_certificate
      t.string :other_documents

      t.timestamps
    end
  end
end

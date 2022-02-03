class CreateCertificatationPathReports < ActiveRecord::Migration[5.2]
  def change
    create_table :certificatation_path_reports do |t|
      t.references :certification_path, foreign_key: true
      t.string :reference_number
      t.string :to
      t.string :project_owner
      t.string :project_name
      t.string :project_location
      t.date :issuance_date
      t.date :approval_date

      t.timestamps
    end
  end
end

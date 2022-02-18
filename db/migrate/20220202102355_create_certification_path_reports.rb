class CreateCertificationPathReports < ActiveRecord::Migration[5.2]
  def change
    create_table :certification_path_reports do |t|
      t.references :certification_path, foreign_key: true
      t.string :reference_number
      t.string :to
      t.string :project_owner
      t.string :project_name
      t.string :project_location
      t.date :issuance_date
      t.date :approval_date
      t.date :release_date
      t.boolean :is_released, default: false

      t.timestamps
    end

    # Reset pk sequence of certification_path_statuses table
    ActiveRecord::Base.connection.reset_pk_sequence!("certification_path_statuses")

    # adding certification status
    CertificationPathStatus.find_or_create_by(
      name: 'Certificate In Process',
      past_name: 'Certificate Generated',
      description: 'Certificate In Process - after Chairman approval'
    )
  end
end
